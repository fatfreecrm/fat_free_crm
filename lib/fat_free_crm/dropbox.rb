# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
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
require "net/imap"
require "mail"
include Rails.application.routes.url_helpers

module FatFreeCRM
  class Dropbox

    ASSETS   = [ Account, Contact, Lead ].freeze
    KEYWORDS = %w(account campaign contact lead opportunity).freeze

    #--------------------------------------------------------------------------------------
    def initialize
      @settings = Setting.email_dropbox
      @archived, @discarded = 0, 0
    end

    #--------------------------------------------------------------------------------------
    def run
      log "connecting to #{@settings[:server]}..."
      connect! or return nil
      log "logged in to #{@settings[:server]}..."
      with_new_emails do |uid, email|
        process(uid, email)
        archive(uid)
      end
    ensure
      log "messages processed: #{@archived + @discarded}, archived: #{@archived}, discarded: #{@discarded}."
      disconnect!
    end

    # Setup imap folders in settings.
    #--------------------------------------------------------------------------------------
    def setup
      log "connecting to #{@settings[:server]}..."
      connect!(:setup => true) or return nil
      log "logged in to #{@settings[:server]}, checking folders..."
      folders = [ @settings[:scan_folder] ]
      folders << @settings[:move_to_folder] unless @settings[:move_to_folder].blank?
      folders << @settings[:move_invalid_to_folder] unless @settings[:move_invalid_to_folder].blank?

      # Open (or create) destination folder in read-write mode.
      folders.each do |folder|
        if @imap.list("", folder)
          log "folder #{folder} OK"
        else
          log "folder #{folder} missing, creating..."
          @imap.create(folder)
        end
      end
    rescue => e
      $stderr.puts "setup error #{e.inspect}"
    ensure
      disconnect!
    end

    private

    #--------------------------------------------------------------------------------------
    def with_new_emails
      @imap.uid_search(['NOT', 'SEEN']).each do |uid|
        begin
          email = Mail.new(@imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
          log "fetched new message...", email
          if is_valid?(email) && sent_from_known_user?(email)
            yield(uid, email)
          else
            discard(uid)
          end
        rescue Exception => e
          if ["test", "development"].include?(Rails.env)
            $stderr.puts e
            $stderr.puts e.backtrace
          end
          log "error processing email: #{e.inspect}", email
          discard(uid)
        end
      end
    end

    # Email processing pipeline: each steps gets executed if previous one returns false.
    #--------------------------------------------------------------------------------------
    def process(uid, email)
      with_explicit_keyword(email) do |keyword, name|
        data = {"Type" => keyword, "Name" => name}
        find_or_create_and_attach(email, data)
      end and return

      with_recipients(email) do |recipient|
        find_and_attach(email, recipient)
      end and return

      with_forwarded_recipient(email) do |recipient|
        find_and_attach(email, recipient)
      end and return

      with_recipients(email) do |recipient|
        create_and_attach(email, recipient)
      end and return

      with_forwarded_recipient(email) do |recipient|
        create_and_attach(email, recipient)
      end
    end

    # Connects to the imap server with the loaded settings from settings.yml
    #------------------------------------------------------------------------------
    def connect!(options = {})
      @imap = Net::IMAP.new(@settings[:server], @settings[:port], @settings[:ssl])
      @imap.login(@settings[:user], @settings[:password])
      @imap.select(@settings[:scan_folder]) unless options[:setup]
      @imap
    rescue Exception => e
      $stderr.puts "Dropbox: could not login to the IMAP server: #{e.inspect}" unless Rails.env == "test"
      nil
    end

    #------------------------------------------------------------------------------
    def disconnect!
      if @imap
        @imap.logout
        unless @imap.disconnected?
          @imap.disconnect rescue nil
        end
      end
    end

    # Discard message (not valid) action based on settings from settings.yml
    #------------------------------------------------------------------------------
    def discard(uid)
      if @settings[:move_invalid_to_folder]
        @imap.uid_copy(uid, @settings[:move_invalid_to_folder])
      end
      @imap.uid_store(uid, "+FLAGS", [:Deleted])
      @discarded += 1
    end

    # Archive message (valid) action based on settings from settings.yml
    #------------------------------------------------------------------------------
    def archive(uid)
      if @settings[:move_to_folder]
        @imap.uid_copy(uid, @settings[:move_to_folder])
      end
      @imap.uid_store(uid, "+FLAGS", [:Seen])
      @archived += 1
    end

    #------------------------------------------------------------------------------
    def is_valid?(email)
      valid = email.content_type != "text/html"
      log("not a text message, discarding") unless valid
      valid
    end

    #------------------------------------------------------------------------------
    def sent_from_known_user?(email)
      email_address = email.from.first
      known = !find_sender(email_address).nil?
      log("sent by unknown user #{email_address}, discarding") unless known
      known
    end

    #------------------------------------------------------------------------------
    def find_sender(email_address)
      @sender = User.where('lower(email) = ? AND suspended_at IS NULL', email_address.downcase).first
    end

    # Checks the email to detect keyword on the first line.
    #--------------------------------------------------------------------------------------
    def with_explicit_keyword(email)
      first_line = plain_text_body(email).split("\n").first
      if first_line =~ %r|^[\./]?(#{KEYWORDS.join('|')})\s(.+)$|i
        yield $1.capitalize, $2.strip
      end
    end

    # Checks the email to detect assets on to/bcc addresses
    #--------------------------------------------------------------------------------------
    def with_recipients(email, options = {})
      recipients = []
      recipients += email.to_addrs unless email.to.blank?
      recipients += email.cc_addrs unless email.cc.blank?
      recipients -= [ @settings[:address] ]
      recipients.inject(false) { |attached, recipient| attached ||= yield recipient }
    end

    # Checks the email to detect valid email address in body (first email), detect forwarded emails
    #----------------------------------------------------------------------------------------
    def with_forwarded_recipient(email, options = {})
      if plain_text_body(email) =~ /\b([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4})\b/
        yield $1
      end
    end

    # Process pipe_separated_data or explicit keyword.
    #--------------------------------------------------------------------------------------
    def find_or_create_and_attach(email, data)
      klass = data["Type"].constantize

      if data["Email"] && klass.new.respond_to?(:email)
        conditions = ['email = ?', data["Email"]]
      elsif klass.new.respond_to?(:first_name)
        first_name, *last_name = data["Name"].split
        conditions = if last_name.empty? # Treat single name as last name.
          [ 'last_name LIKE ?', "%#{first_name}" ]
        else
          [ 'first_name LIKE ? AND last_name LIKE ?', "%#{first_name}", "%#{last_name.join(' ')}" ]
        end
      else
        conditions = ['name LIKE ?', "%#{data["Name"]}%"]
      end

      # Find the asset from deduced conditions
      if asset = klass.where(conditions).first
        if sender_has_permissions_for?(asset)
          attach(email, asset, :strip_first_line)
        else
          log "Sender does not have permissions to attach email to #{data["Type"]} #{data["Email"]} <#{data["Name"]}>"
        end
      else
        log "#{data["Type"]} #{data["Email"]} <#{data["Name"]}> not found, creating new one..."
        asset = klass.create!(default_values(klass, data))
        attach(email, asset, :strip_first_line)
      end
      true
    end

    #----------------------------------------------------------------------------------------
    def find_and_attach(email, recipient)
      attached = false
      ASSETS.each do |klass|
        asset = klass.find_by_email(recipient)

        # Leads and Contacts have an alt_email: try it if lookup by primary email has failed.
        if !asset && klass.column_names.include?("alt_email")
          asset = klass.find_by_alt_email(recipient)
        end

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
    def attach(email, asset, strip_first_line=false)
      to = email.to.blank? ? nil : email.to.join(", ")
      cc = email.cc.blank? ? nil : email.cc.join(", ")

      email_body = if strip_first_line
        plain_text_body(email).split("\n")[1..-1].join("\n").strip
      else
        plain_text_body(email)
      end

      Email.create(
        :imap_message_id => email.message_id,
        :user            => @sender,
        :mediator        => asset,
        :sent_from       => email.from.first,
        :sent_to         => to,
        :cc              => cc,
        :subject         => email.subject,
        :body            => email_body,
        :received_at     => email.date,
        :sent_at         => email.date
      )
      asset.touch

      if asset.is_a?(Lead) && asset.status == "new"
        asset.update_attribute(:status, "contacted")
      end

      if @settings[:attach_to_account] && asset.respond_to?(:account) && asset.account
        Email.create(
          :imap_message_id => email.message_id,
          :user            => @sender,
          :mediator        => asset.account,
          :sent_from       => email.from.first,
          :sent_to         => to,
          :cc              => cc,
          :subject         => email.subject,
          :body            => email_body,
          :received_at     => email.date,
          :sent_at         => email.date
        )
        asset.account.touch
      end
    end

    #----------------------------------------------------------------------------------------
    def default_values(klass, data)
      data = data.dup
      keyword = data.delete("Type").capitalize

      defaults = {
        :user   => @sender,
        :access => default_access
      }

      case keyword
      when "Account", "Campaign", "Opportunity"
        defaults[:status] = "planned" if keyword == "Campaign"      # TODO: I18n
        defaults[:stage] = "prospecting" if keyword == "Opportunity" # TODO: I18n

      when "Contact", "Lead"
        first_name, *last_name = data.delete("Name").split(' ')
        defaults[:first_name] = first_name
        defaults[:last_name] = (last_name.any? ? last_name.join(" ") : "(unknown)")
        defaults[:status] = "contacted" if keyword == "Lead"        # TODO: I18n
      end

      data.each do |key, value|
        key = key.downcase
        defaults[key.to_sym] = value if klass.new.respond_to?(key + '=')
      end

      defaults
    end

    #----------------------------------------------------------------------------------------
    def default_values_for_contact(email, recipient)
      recipient_local, recipient_domain = recipient.split('@')

      defaults = {
        :user       => @sender,
        :first_name => recipient_local.capitalize,
        :last_name  => "(unknown)",
        :email      => recipient,
        :access     => default_access
      }

      # Search for domain name in Accounts.
      account = Account.where('email like ?', "%#{recipient_domain}").first
      if account
        log "asociating new contact #{recipient} with the account #{account.name}"
        defaults[:account] = account
      else
        log "creating new account #{recipient_domain.capitalize} for the contact #{recipient}"
        defaults[:account] = Account.create!(
          :user   => @sender,
          :email  => recipient,
          :name   => recipient_domain.capitalize,
          :access => default_access
        )
      end
      defaults
    end

    # If default access is 'Shared' then change it to 'Private' because we don't know how
    # to choose anyone to share it with here.
    #--------------------------------------------------------------------------------------
    def default_access
      Setting.default_access == "Shared" ? 'Private' : Setting.default_access
    end

    #--------------------------------------------------------------------------------------
    def sender_has_permissions_for?(asset)
      return true if asset.access == "Public"
      return true if asset.user_id == @sender.id || asset.assigned_to == @sender.id
      return true if asset.access == "Shared" && Permission.where('user_id = ? AND asset_id = ? AND asset_type = ?', @sender.id, asset.id, asset.class.to_s).count > 0

      false
    end

    # Notify users with the results of the operations (feedback from dropbox)
    #--------------------------------------------------------------------------------------
    def notify(email, mediator_links)
      ack_email = Notifier.create_dropbox_ack_notification(@sender, @settings[:address], email, mediator_links)
      Notifier.deliver(ack_email)
    end

    # Centralized logging.
    #--------------------------------------------------------------------------------------
    def log(message, email = nil)
      return if Rails.env == "test"
      puts "Dropbox: #{message}"
      puts "  From: #{email.from}, Subject: #{email.subject} (#{email.message_id})" if email
    end

    # Returns the plain-text version of an email, or strips html tags
    # if only html is present.
    #--------------------------------------------------------------------------------------
    def plain_text_body(email)
      parts = email.parts.collect {|c| (c.respond_to?(:parts) && !c.parts.empty?) ? c.parts : c}.flatten
      if parts.empty?
        parts << email
      end
      plain_text_part = parts.detect {|p| p.content_type.include?('text/plain')}
      if plain_text_part.nil?
        # no text/plain part found, assuming html-only email
        # strip html tags and remove doctype directive
        plain_text_body = email.body.to_s.gsub(/<\/?[^>]*>/, "")
        plain_text_body.gsub! %r{^<!DOCTYPE .*$}, ''
      else
        plain_text_body = plain_text_part.body.to_s
      end
      plain_text_body.strip.gsub("\r\n", "\n")
    end

  end # class Dropbox
end # module FatFreeCRM

