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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :mailchimp do
    desc "check mailchimp lists for consistency"
    task :check => :environment do
      lists = ["adelaide", "city_west", "city_east"]
      
      lists.each do |list|
        list_id = Setting.mailchimp["#{list}_list_id"]
        list_key = Setting.mailchimp["#{list}_api_key"]

        api = Mailchimp::API.new(list_key, :throws_exceptions => true)
        r = api.list_members(:id => list_id, :limit => "1000")
        emails_at_mailchimp = r["data"].collect.each { |lm| lm["email"].gsub(/\s+/, "").downcase }
        
        list_contacts = Contact.where("cf_weekly_emails LIKE ?", "%#{list.titleize}%")
        emails_in_crm = list_contacts.collect.each { |c| c.email.to_s.gsub(/\s+/, "").downcase }
        emails_in_crm.reject!(&:blank?)
        
        subscribed_with_no_email = Contact.where("cf_weekly_emails LIKE ? AND email IS NULL", "%#{list.titleize}%")
        invalids = subscribed_with_no_email.collect.each { |c| c.first_name + " " + c.last_name}
        
        puts "*******************************"
        puts "*** LIST: #{list.titleize} ****"
        puts "*******************************"
        puts "\n"
        puts "emails at mailchimp, but not in crm:"
        puts "____________________________________"
        puts (emails_at_mailchimp - emails_in_crm).join("\n")
        puts "\n"
        puts "emails in crm, but not at mailchimp:"
        puts "____________________________________"
        puts (emails_in_crm - emails_at_mailchimp).join("\n")
        puts "\n"
        puts "subscribed to list in CRM, but no email address (invalid):"
        puts "____________________________________"
        puts (invalids).join("\n")
        puts "\n"
        
      end
      
    end
  end
  
  namespace :gonecold do
    desc "Scan for contacts that have gone cold"
    task :find => :environment do
      # Load fixtures
      require 'active_record/fixtures'
      campuses = []
      #campuses << Account.find_by_name("Adelaide Uni")
      campuses << Account.find_by_name("City East")
      campuses << Account.find_by_name("City West")
      campuses -= [nil]
      
      campuses.each do |campus|
        campus.contacts.each do |contact|
          last_time_at_tbt = contact.last_attendance_at_event_category(:bible_talk)
          last_time_at_bsg = contact.last_attendance_at_event_category(:bsg)
          things_missed = []
          things_missed << "TBT" if last_time_at_tbt.nil?
          things_missed << "BSG" if last_time_at_bsg.nil?
          
          if last_time_at_tbt.nil? || last_time_at_bsg.nil? || last_time_at_tbt < (Time.now - 2.weeks) || last_time_at_bsg < (Time.now - 2.weeks)
            if contact.tasks.where('name LIKE (?)', "Has not been at%").empty?
              contact.tasks << Task.new(
                    :user => User.find(1), 
                    :name => "Has not been at #{things_missed.to_sentence(:two_words_connector => " or ")} during the last 2 weeks", 
                    :category => :follow_up, 
                    :bucket => "due_this_week"
                    ) 
              contact.save
              puts "#{contact.first_name} #{contact.last_name} has gone cold on #{things_missed.to_sentence}"
            end
          end
        end
      end  
      puts "Done checking cold contacts"
    end
  end
  
  namespace :registrations do
    desc "sync registrants from website registration data"
    task :sync => :environment do
      
      require 'open-uri'
      
      PaperTrail.whodunnit = 1
      url = Setting.registration_api[:ccamp_link]
      url_data = open(url).read()
      
      group = ContactGroup.find_or_initialize_by_name(
          :name => "Commencement Camp 2013",
          :access => Setting.default_access,
          :user_id => 1
          )
        unless group.persisted?
          group.save
        end
      
      csv = CSV.parse(url_data, {:col_sep => ',', :headers => :first_row, :header_converters => :symbol}) 
      csv.each do |row|
        unless group.contacts.find_by_email(row[:_email])
        #sync has already brought this contact in and placed it in the group, skip...
          contact = Contact.find_by_email(row[:_email])
          if contact.nil?
            contact = Contact.find_or_initialize_by_mobile(row[:_mobile].gsub(/[\(\) ]/, ""))
            contact.update_attributes(:alt_email => contact.email) if contact.persisted? #email must have changed
            log_string = "Contact found by mobile. updated: "
          end
           
          if row[:_course_year_in_2013] == "1"
            contact.cf_year_commenced = "2013"
          end
          
          contact.business_address = Address.new
          contact.business_address.street1 = row[:_address]
          contact.business_address.street2 = row[:_address2]
          contact.business_address.city = row[:_suburb]
          contact.business_address.state = row[:_state]
          contact.business_address.zipcode = row[:_post_code]
          contact.business_address.country = "Australia"
          contact.business_address.address_type = "Business"   
          
          unless contact.assigned_to.present?
            if (row[:_campus] == "City East" || row[:_campus] == "City West")
              contact.cf_weekly_emails << row[:_campus] unless contact.cf_weekly_emails.include?(row[:_campus])
              user = User.find_by_first_name("dave")
            elsif (row[:_campus] == "Adelaide")
              contact.cf_weekly_emails << row[:_campus] unless contact.cf_weekly_emails.include?(row[:_campus])
              user = (row[:_gender] == "Male") ? User.find_by_first_name("reuben") : User.find_by_first_name("laura")
            else
              user = User.find_by_first_name("geoff")
            end
            contact.assigned_to = user.id#reuben or laura
          end
          
          unless contact.account.present?
            contact.account = Account.find_or_create_by_name(row[:_campus]) 
            contact.account.user = User.find(1)
          end
          
          if !contact.persisted?
            contact.user_id = 1
            contact.access = Setting.default_access

            log_string = "Created new contact: "
          else
            log_string = "Contact found by email. updated: " if log_string.nil?
          end
          
          contact.update_attributes(
            :first_name => row[:_first_name],
            :last_name => row[:_last_name],
            :email => row[:_email],
            :cf_gender => row[:_gender],
            :phone => row[:_home_phone],
            :mobile => row[:_mobile].gsub(/[\(\) ]/, ""),
            #address?
            :cf_campus => row[:_campus],
            :cf_course_1 => row[:_course],
            :cf_church_affiliation => row[:_church_if_you_attend_one],
            :cf_expected_grad_year => row[:_year_i_expect_to_graduate]
           )
          
          puts (log_string + contact.first_name + " " + contact.last_name)
          
          contact.save
          
          contacts_with_name = Contact.where(:first_name => contact.first_name, :last_name => contact.last_name)
          if contacts_with_name.size > 1
            contact.tasks << Task.new(
                  :name => "Possible duplicate from registration sync", :category => :follow_up, :bucket => "due_this_week", :user => User.find_by_first_name("reuben")
                  )
          end
          
          group.contacts << contact unless group.contacts.include?(contact) #shouldn't happen, but just in case
        end
      end
      
    end
  end
  
end
