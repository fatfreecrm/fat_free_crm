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
          unless @user = is_valid(email)
            discard
          else                    
            # Search for ENTITIES [Campaign/Opportunity] on the first line of body (identify forwarded emails)
            if entity = is_for_entity(email)
              log("Detected entity", email)
              process_entity(email, entity)
            else
              # Search for assets emails
              if recipients_assets = is_for_recipients(email)
                log("Detected recipients", email)
                add_to(email, recipients_assets)
              else # Search forwarded emails
                if forwarded_asset = is_forwarded(email)
                  log("Detected forward", email)
                  add_to(email, forwarded_asset)
                else
                  log("Discarding", email)
                  discard
                end              
              end            
            end
          end              
        rescue Exception => e
          logger.error "Dropbox - Problem processing email: #{e}"
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
    def archive(uid)
      if @settings[:move_to_folder]
        @imap.uid_copy(@current_uid, @settings[:move_to_folder])   
      end      
      @imap.uid_store(@current_uid, "+FLAGS", [:Seen])  
    end    

    # Checks if an email is valid (plain text and is from an email of valid user)
    # TODO: Change find_by_email to not return disabled users
    #------------------------------------------------------------------------------     
    def is_valid(email)      
      if email.content_type != "text/plain"
        log("Discarding... not text/plain", email)
        return false
      end
      User.find_by_email(email.from.first.downcase) || nil
    end

    # Checks the email to detect entity on the first line (forward to Campaing/Opportunity)
    #--------------------------------------------------------------------------------------     
    def is_for_entity(email)
      ENTITIES.each do |entity|
        if email.body.split("\n").first.include? entity
          return { :type => entity, :name => email.body.split("\n").first.gsub(entity, "") }
        end
      end
      return false
    end   

    # Checks the email to detect assets on to/bcc addresses
    #--------------------------------------------------------------------------------------     
    def is_for_recipients(email)
      # Find assets on to, cc email addresses
      email.to.blank? ? to = [] : to = email.to
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

    # Process allready identified entity mark
    #--------------------------------------------------------------------------------------    
    def process_entity(email, entity)
      asset = entity[:type].constantize.find(:first, :conditions => ['name LIKE ?', "%#{entity[:name].chomp.strip}%"], :order => "updated_at DESC")     
      if asset.blank? 
        notify("not_found_entity")
      else
        add_to(email, [asset])
      end
      archive(email)
    end

    # Add mail to assets. assets should be an array of asset objects
    #--------------------------------------------------------------------------------------    
    def add_to(email, assets)
      if email.to.blank?
        log("Discarding... missing To header", email)
      else
        to = email.to.join(", ")
      end
      email.cc.blank? ? cc = "" : cc = email.cc.join(", ")
      
      assets.each do |asset|
        Email.create(:imap_message_id => email.message_id, :user => @user, :mediator => asset, :from => email.from.first, :to => to, :cc => cc, :subject => email.subject, :body => email.body, :received_at => email.date)
        log("Added email to asset #{asset.class.to_s} with name #{asset.name}", email)
      end
      archive(email)
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
    
    # Centralized loggin
    #--------------------------------------------------------------------------------------      
    def log(msg, email)  
      logger.info "dropbox - #{msg} in email #{email.message_id} from #{email.from} with subject #{email.subject}" if @settings[:debug]
    end
    
  end # class Dropbox
end # module FatFreeCRM