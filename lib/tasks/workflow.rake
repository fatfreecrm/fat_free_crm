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
      
      require 'active_record/fixtures'
      require 'open-uri'
      
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
          
          if !contact.persisted?
            contact.update_attributes(
            :user_id => 1,
            :access => Setting.default_access
            )
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
          
          if (contact.cf_campus == "City East" || contact.cf_campus == "City West")
            user = User.find_by_first_name("dave")
          elsif (contact.cf_campus == "Adelaide")
            user = (contact.cf_gender == "Male") ? User.find_by_first_name("reuben") : User.find_by_first_name("laura")
          else
            user = User.find_by_first_name("geoff")
          end
          
          contact.assigned_to = user.id #reuben or laura
          contact.account = Account.find_or_create_by_name(contact.cf_campus)
          contact.account.user = User.find(1)
          
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
