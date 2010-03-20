# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------
# TODO:
#  - Make options for: (attach email to accont of contact if has
require "net/imap"
require "tmail_mail_extension"
include ActionController::UrlWriter

module FatFreeCRM
  class Dropbox
    
    ASSETS   = [ Account, Contact, Lead ].freeze
    KEYWORDS = %w(account campaign contact lead opportunity).freeze
    
    #-------------------------------------------------------------------------------------- 
    def initialize
      @settings = Setting[:email_dropbox]
    end
    
    #-------------------------------------------------------------------------------------- 
    def run
      connect! or return nil
      with_new_emails do |uid, email|
        process(uid, email)
        archive(uid)
      end
    ensure
      disconnect!
    end

    private

    #-------------------------------------------------------------------------------------- 
    def with_new_emails
      @imap.uid_search(['NOT', 'SEEN']).each do |uid|
        begin
          email = TMail::Mail.parse(@imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
          if is_valid?(email) && sent_from_known_user?(email)
            yield(uid, email)
          else
            discard(uid)
          end
        rescue Exception => e
          if Rails.env == "test"
            $stderr.puts e
            $stderr.puts e.backtrace
          end
          log("Problem processing email: #{e}", email)
          discard(uid)
        end
      end
    end

    # Email processing pipeline: each steps gets executed if previous one returns false.
    #--------------------------------------------------------------------------------------
    def process(uid, email)
      with_explicit_keyword(email) do |keyword, name|
        find_or_create_and_attach(email, keyword, name)
      end and return

      with_recipients(email) do |recipient|
        find_and_attach(email, recipient)
      end and return

      with_forwarded_recipient(email) do |recipient|
        find_and_attach(email, recipient)
      end and return
  
      with_recipients(email, :parse => true) do |recipient|
        create_and_attach(email, recipient)
      end and return

      with_forwarded_recipient(email, :parse => true) do |recipient|
        create_and_attach(email, recipient)
      end
    end
    
    # Connects to the imap server with the loaded settings from settings.yml
    #------------------------------------------------------------------------------    
    def connect!
      begin  
        @imap = Net::IMAP.new(@settings[:server], @settings[:port], @settings[:ssl])
        @imap.login(@settings[:user], @settings[:password])
        @imap.select(@settings[:scan_folder])
      rescue Exception => e
        logger.error "dropbox - Problem setting connection with imap server: #{e}"
        nil
      end
    end

    #------------------------------------------------------------------------------    
    def disconnect!
      if @imap && !@imap.disconnected?
        @imap.logout
        @imap.disconnect
      end
    end

    # Discard message (not valid) action based on settings from settings.yml
    #------------------------------------------------------------------------------ 
    def discard(uid)
      if @settings[:move_invalid_to_folder]
        @imap.uid_copy(uid, @settings[:move_invalid_to_folder])   
      end      
      @imap.uid_store(uid, "+FLAGS", [:Deleted])      
    end

    # Archive message (valid) action based on settings from settings.yml
    #------------------------------------------------------------------------------     
    def archive(uid)
      if @settings[:move_to_folder]
        @imap.uid_copy(uid, @settings[:move_to_folder])
      end      
      @imap.uid_store(uid, "+FLAGS", [:Seen])
    end    

    #------------------------------------------------------------------------------
    def is_valid?(email)
      email.content_type == "text/plain"
      # TODO: add logging
    end

    #------------------------------------------------------------------------------
    def sent_from_known_user?(email)
      !find_sender(email).nil?
    end

    #------------------------------------------------------------------------------
    def find_sender(email)
      @sender = User.first(:conditions => ['email = ? AND suspended_at IS NULL', email.from.first.downcase])
    end

    # Checks the email to detect keyword on the first line.
    #--------------------------------------------------------------------------------------     
    def with_explicit_keyword(email)
      first_line = email.body.split("\n").first

      if first_line =~ %r|^[\./]?(#{KEYWORDS.join('|')})\s(.+)$|i
        yield $1.capitalize, $2.strip
      end
    end   

    # Checks the email to detect assets on to/bcc addresses
    #--------------------------------------------------------------------------------------     
    def with_recipients(email, options = {})
      recipients = []
      unless options[:parse]
        # Plain email addresses.
        recipients += email.to_addrs.map(&:address) unless email.to.blank?
        recipients += email.cc_addrs.map(&:address) unless email.cc.blank?
        recipients -= [ @settings[:dropbox_email] ]
      else
        # TMail::Address objects.
        recipients += email.to_addrs unless email.to.blank?
        recipients += email.cc_addrs unless email.cc.blank?
        recipients -= [ TMail::Address.parse(@settings[:dropbox_email]) ]
      end
      recipients.inject(false) { |attached, recipient| attached ||= yield recipient }
    end

    # Checks the email to detect valid email address in body (first email), detect forwarded emails
    #----------------------------------------------------------------------------------------     
    def with_forwarded_recipient(email, options = {})
      if email.body =~ /\b([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4})\b/
        yield(options[:parse] ? TMail::Address.parse($1) : $1)
      end
    end


    # Process allready identified keyword mark
    #--------------------------------------------------------------------------------------    
    def find_or_create_and_attach(email, keyword, name)
      asset = keyword.constantize.first(:conditions => [ "name LIKE ?", "%#{name}%" ])
      if asset
        attach(email, asset) if sender_has_permissions_for?(asset)
      else
        log("keyword not found (will try to create new): #{keyword} with name #{name}", email)
        asset = keyword.constantize.create(default_values(email, keyword, name))
        attach(email, asset)
      end
      true
    end

    #----------------------------------------------------------------------------------------      
    def find_and_attach(email, recipient)
      attached = false
      ASSETS.each do |klass|
        asset = klass.find_by_email(recipient)
        if asset && sender_has_permissions_for?(asset)
          attach(email, asset)
          attached = true
        end
      end
      attached
    end

    #----------------------------------------------------------------------------------------      
    def create_and_attach(email, recipient)
      contact = Contact.create!(default_values_for_contact(email, recipient))
      attach(email, contact)
    end

    #----------------------------------------------------------------------------------------      
    def attach(email, asset)
      to = email.to.blank? ? nil : email.to.join(", ")
      cc = email.cc.blank? ? nil : email.cc.join(", ")

      Email.create(
        :imap_message_id => email.message_id,
        :user            => @sender,
        :mediator        => asset,
        :sent_from       => email.from.first,
        :sent_to         => to,
        :cc              => cc,
        :subject         => email.subject,
        :body            => email.body_plain,
        :received_at     => email.date,
        :sent_at         => email.date
      )

      if @settings[:attach_to_account] && asset.respond_to?(:account) && asset.account
        Email.create(
          :imap_message_id => email.message_id,
          :user            => @sender,
          :mediator        => asset.account,
          :sent_from       => email.from.first,
          :sent_to         => to,
          :cc              => cc,
          :subject         => email.subject,
          :body            => email.body_plain,
          :received_at     => email.date,
          :sent_at         => email.date
        )
      end
    end

    #----------------------------------------------------------------------------------------      
    def default_values(email, keyword, name)
      defaults = { 
        :user   => @sender,
        :name   => name,
        :access => Setting.default_access
      }
      defaults[:status] = "planned" if keyword == "Campaign"       # TODO: I18n
      defaults[:stage] = "prospecting" if keyword == "Oportunity"
      defaults
    end

    #----------------------------------------------------------------------------------------      
    def default_values_for_contact(email, recipient)
      defaults = {
        :user       => @sender,
        :first_name => recipient.local.capitalize,
        :last_name  => "(unknown)",
        :email      => recipient.address,
        :access     => Setting.default_access
      }
      
      # Search for domain name in Accounts.
      account = Account.first(:conditions => [ "email like ?", "%#{recipient.domain}" ])
      if account
        log("asociating new contact from #{addr.spec} to account #{account.name}", email)
        defaults[:account] = account
      else
        log("creating new account (#{recipient.domain}) to the new contact from #{recipient.spec}", email)
        defaults[:account] = Account.create(
          :user   => @sender,
          :name   => recipient.domain.capitalize,
          :access => Setting.default_access
        )
      end
      defaults
    end

    #--------------------------------------------------------------------------------------      
    def sender_has_permissions_for?(asset)
      return true if asset.access == "Public"
      return true if asset.user_id == @sender.id || asset.assigned_to == @sender.id
      return true if asset.access == "Shared" && Permission.count(:conditions => [ "user_id = ? AND asset_id = ? AND asset_type = ?", @sender.id, asset.id, asset.class.to_s ]) > 0
      
      false    
    end

    # Notify users with the results of the operations (feedback from dropbox)
    #--------------------------------------------------------------------------------------      
    def notify(email, mediator_links)      
      ack_email = Notifier.create_dropbox_ack_notification(@sender, @settings[:dropbox_email], email, mediator_links)
      Notifier.deliver(ack_email)
    end
    
    # Setup imap folders in settings
    #--------------------------------------------------------------------------------------      
    def setup
      puts "dropbox - Checking folders in configuration"
      connect(false)
      folders = [@settings[:scan_folder]]
      folders << @settings[:move_to_folder] unless @settings[:move_to_folder].blank?
      folders << @settings[:move_invalid_to_folder] unless @settings[:move_invalid_to_folder].blank?
      
      # Open (or create) destination folder in read-write mode.
      begin
        folders.each do |@check_folder|             
          @imap.select(@check_folder)
          puts "dropbox - succefull selected folder '#{@check_folder}'"
        end
      rescue => e
        begin
          puts " - folder #{@check_folder} not found; creating..."
          @imap.create(@check_folder)
          @imap.select(@check_folder)
          puts "dropbox - succefull created and selected folder '#{@check_folder}'"
        rescue => ee
          puts "Error: could not create folder #{@check_folder}: #{e}"
          next
        end
      end  
      
    end

    # Setup logger
    #-------------------------------------------------------------------------------------- 
    def logger
      RAILS_DEFAULT_LOGGER
    end    
    
    # Centralized logging
    #--------------------------------------------------------------------------------------      
    def log(msg, email)  
      logger.info "dropbox - #{msg} in email #{email.message_id} from #{email.from} with subject #{email.subject}" if @settings[:debug]
    end
    
  end # class Dropbox
end # module FatFreeCRM