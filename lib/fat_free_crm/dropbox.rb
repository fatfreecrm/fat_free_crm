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
require 'net/imap'
require 'tmail'

module FatFreeCRM
  class Dropbox
    
    ENTITIES = ["Campaign", "Opportunity"]
    ASSETS   = [Account, Contact, Lead] # The order gave priority to the asset
    
    def initialize
      @settings = Setting[:email_dropbox]
    end
    
    def run
      connect
      # Loop on not seen emails
      @imap.uid_search(['NOT', 'SEEN']).each do |uid|        
        begin  
          @current_uid = uid
          email = TMail::Mail.parse(@imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
          unless @current_user = validate_and_find_user(email)
            discard
          else                    
            # Search for ENTITIES [Campaign/Opportunity] on the first line of body (identify forwarded emails)
            if entity = is_for_entity(email)
              log("Detected entity", email)
              process_entity(email, entity)
            else
              # Search for assets in email recipients
              if recipients_assets = is_for_recipients(email)
                log("Detected recipients", email)
                add_to(email, recipients_assets)
              else # Search forwarded emails
                if forwarded_asset = is_forwarded(email)
                  log("Detected forward", email)
                  add_to(email, forwarded_asset)
                else
                  # Detect recipients and fwd emails and try to create new contacts, discard if none found
                  new_contacts_or_discard(email)
                end              
              end            
            end
          end              
        rescue Exception => e
          log("Problem processing email: #{e}", email)
          next
        end
      end # loop
      disconnect     
    end       
    
    # Connects to the imap server with the loaded settings from settings.yml
    #------------------------------------------------------------------------------    
    def connect(select = true)
      begin  
        @imap = Net::IMAP.new(@settings[:server], @settings[:port], @settings[:ssl])
        @imap.login(@settings[:user], @settings[:password])
        @imap.select(@settings[:scan_folder]) if select == true
      rescue Exception => e
        logger.error "Dropbox - Problem setting connection with imap server: #{e}"
        exit
      end
    end

    def disconnect
      @imap.logout
      @imap.disconnect      
    end

    # Discard message (not valid) action based on settings from settings.yml
    #------------------------------------------------------------------------------ 
    def discard
      if @settings[:move_invalid_to_folder]
        @imap.uid_copy(@current_uid, @settings[:move_invalid_to_folder])   
      end      
      @imap.uid_store(@current_uid, "+FLAGS", [:Deleted])      
    end

    # Archive message (valid) action based on settings from settings.yml
    #------------------------------------------------------------------------------     
    def archive
      if @settings[:move_to_folder]
        @imap.uid_copy(@current_uid, @settings[:move_to_folder])
      end      
      @imap.uid_store(@current_uid, "+FLAGS", [:Seen])
    end    

    # Checks if an email is valid (plain text and is from an email of valid user)
    #------------------------------------------------------------------------------     
    def validate_and_find_user(email)
      if email.content_type != "text/plain"
        log("Discarding... not text/plain", email)
        return nil
      end
      User.first(:conditions => ['email = ? AND suspended_at IS NULL', email.sent_from.first.downcase])
    end

    # Checks the email to detect entity on the first line (forward to Campaing/Opportunity)
    #--------------------------------------------------------------------------------------     
    def is_for_entity(email)
      ENTITIES.each do |entity|
        if email.body.split("\n").first.include? entity
          return { :type => entity, :name => email.body.split("\n").first.gsub(entity, "").chomp.strip }
        end
      end
      return false
    end   

    # Process allready identified entity mark
    #--------------------------------------------------------------------------------------    
    def process_entity(email, entity)
      asset = entity[:type].constantize.find(:first, :conditions => ['name LIKE ?', "%#{entity[:name]}%"], :order => "updated_at DESC")     
      if asset.blank? 
        log("entity not found (will try to create new): #{entity[:type]} with name #{entity[:name]}", email)
        asset = entity[:type].constantize.create(get_new_entity_defaults(email, entity))
        add_to(email, [asset])
      else
        add_to(email, [asset])
      end
    end
    
    def get_new_entity_defaults(email, entity)
      # TODO: Maybe the defaults should be more settings
      defaults = { :user => @current_user, :name => entity[:name], :access => Setting.default_access }
      defaults[:status] = "planned" if entity[:type] == "Campaign"
      defaults[:stage] = "prospecting" if entity[:type] == "Opportunity"
      defaults
    end

    # Checks the email to detect assets on to/bcc addresses
    #--------------------------------------------------------------------------------------     
    def is_for_recipients(email)
      # Find assets on to, cc email addresses
      email.sent_to.blank? ? to = [] : to = email.sent_to
      email.cc.blank? ? cc = [] : cc = email.cc
      recipients = to + cc - [@settings[:dropbox_email]]      
      detect_assets(email, recipients)
    end

    # Checks the email to detect valid email address in body (first email), detect forwarded emails
    #----------------------------------------------------------------------------------------     
    def is_forwarded(email)
      # Find first email address in body
      recipient = email.body.scan(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/).first
      detect_assets(email, [recipient])
    end

    # Detects assets on recipients emails
    #----------------------------------------------------------------------------------------      
    def detect_assets(email, recipients)
      detected_assets = []
      ASSETS.each do |asset|
        recipients.each do |recipient|
          asset.to_s == "Lead" ? detected = asset.find(:first, :conditions => ['email = ? and status != ?', recipient, "converted"], :order => "updated_at DESC") : detected = asset.find_by_email(recipient)
          detected_assets << detected unless detected.blank?
        end        
      end
      return nil if detected_assets.blank?
      detected_assets      
    end

    def new_contacts_or_discard(email)
      # Find assets on to, cc email addresses
      email.sent_to.blank? ? to = [] : to = email.sent_to
      email.cc.blank? ? cc = [] : cc = email.cc
      recipients = to + cc - [@settings[:dropbox_email]]
      unless recipients.blank? # mails in to/cc
        recipients.each do |recipient|        
          log("creating new contact from #{recipient}", email)
          contact = Contact.create(get_new_contact_defaults(email, recipient))
          add_to(email, [contact])      
        end
      else # Search FW emails, in body
        recipient = email.body.scan(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/).first
        unless recipient.blank?
          log("creating new contact from email #{recipient}, fwd emails", email)
          contact = Contact.create(get_new_contact_defaults(email, recipient))
          add_to(email, [contact])           
        else
          discard
        end
      end
    end

    def get_new_contact_defaults(email, recipient)
      # TODO: Maybe the defaults should be more settings
      defaults = { :user => @current_user, :first_name => "#{recipient}", :last_name => "Autogenerated", :access => Setting.default_access }
      
      # Search for domain name in accounts
      account = Account.find(:first, :conditions => ['email like ?', "%#{TMail::Address.parse(recipient).domain}"], :order => "updated_at DESC")
      if account.blank?
        log("creating new account (#{TMail::Address.parse(recipient).domain}) to the new contact from #{recipient}", email)
        defaults[:account] = Account.create(:user => @current_user, :name => TMail::Address.parse(recipient).domain, :access => Setting.default_access)
      else
        defaults[:account] = account
        log("asociating new contact from #{recipient} to account #{account.name}", email)
      end
      
      defaults
    end

    # Add mail to assets. assets should be an array of asset objects
    #--------------------------------------------------------------------------------------    
    def add_to(email, assets)
      if email.sent_to.blank?
        log("Discarding... missing To header", email)
      else
        to = email.sent_to.join(", ")
      end
      email.cc.blank? ? cc = "" : cc = email.cc.join(", ")
      
      assets.each do |asset|
        if has_permissions_on(asset)  
          Email.create(:imap_message_id => email.message_id, :user => @current_user, :mediator => asset, :from => email.sent_from.first, :to => to, :cc => cc, :subject => email.subject, :body => email.body, :received_at => email.date)
          archive
          log("Added email to asset #{asset.class.to_s} with name #{asset.name}", email)
          notify("succefully added email")
        else
          discard
          log("Discarding... missing permissions in #{asset.class.to_s}=>#{asset.name} for user #{@current_user.username}", email)
        end
      end
    end

    def has_permissions_on(asset)
      return true if asset.access == "Public"
      return true if asset.access == "Private" && (asset.user_id == @current_user.id || asset.assigned_to == @current_user.id)
      return true if (asset.user_id == @current_user.id || asset.assigned_to == @current_user.id) || ! Permission.find(:first, :conditions => ['user_id = ? and asset_id = ? and asset_type = ?', @current_user.id, asset.id, asset.class.to_s]).blank?
      
      return false    
    end

    # Notify users with the results of the operations (feedback from dropbox)
    #--------------------------------------------------------------------------------------      
    def notify(what)
      puts "WE ARE NOTIFICATION #{what}"
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
      logger.info "dropbox - #{msg} in email #{email.message_id} from #{email.sent_from} with subject #{email.subject}" if @settings[:debug]
    end
    
  end # class Dropbox
end # module FatFreeCRM