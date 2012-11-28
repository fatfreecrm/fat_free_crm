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
  namespace :data do
    desc "Load adelaide data"
    task :load_adelaide => :environment do
      # Load fixtures
      require 'active_record/fixtures'

      CSV.foreach(FatFreeCRM.root.join('db/data-import/adelaide-contacts.csv'), {:col_sep => ',', :headers => :first_row, :header_converters => :symbol}) do |row|

        contact = Contact.find_or_create_by_email(
          :email => row[:email], 
          :user_id => 1, 
          :access => Setting.default_access, :assigned_to => nil,
          :first_name => row[:first_name],
          :last_name => row[:last_name],
          :cf_gender => row[:gender],
          :cf_student_number => row[:student_number],
          :cf_member => !row[:member].blank?,
          :cf_year_commenced => row[:year_commenced],
          :phone => row[:phone],
          :mobile => row[:mobile],
          #address?
          :email => row[:email_1],
          :alt_email => row[:email_2],
          :cf_campus => row[:campus],
          :cf_faculty => row[:faculty],
          :cf_course_1 => row[:course_1],
          :cf_course_2 => row[:course_2],
          :cf_church_affiliation => row[:church_affiliation]
         )
        contact.business_address = Address.new
        contact.business_address.street1 = row[:address]
        contact.business_address.city = row[:suburb]
        contact.business_address.state = row[:state]
        contact.business_address.zipcode = row[:pcode]
        contact.business_address.country = "Australia"
        contact.business_address.address_type = "Business"   
        
        user = (row[:gender] == "Male") ? 1 : 4
        contact.assigned_to = user #reuben or laura
        contact.account = Account.find_or_create_by_name("Adelaide Uni")
        contact.account.user = User.find(1)
        
        contact.save
        
        puts "Added #{contact.name} to Adelaide Uni"

      end
      
      puts
    end
    
    

    desc "Reset the database and reload demo data along with default application settings"
    task :reload => :environment do
      Rake::Task["db:migrate:reset"].invoke
      Rake::Task["ffcrm:demo:load"].invoke
    end
    
    desc "Load unisa data"
    task :load_unisa => :environment do
      # Load fixtures
      require 'active_record/fixtures'

      CSV.foreach(FatFreeCRM.root.join('db/data-import/unisa-contacts.csv'), {:col_sep => ',', :headers => :first_row, :header_converters => :symbol}) do |row|

        contact = Contact.find_or_create_by_email(
          :email => row[:email], 
          :user_id => 1, 
          :access => Setting.default_access, :assigned_to => nil,
          :first_name => row[:first_name],
          :last_name => row[:last_name],
          :cf_gender => row[:gender],
          :cf_student_number => row[:cf_student_number],
          :cf_member => !row[:cf_member].blank?,
          :cf_year_commenced => row[:cf_year_commenced],
          :phone => row[:phone],
          :mobile => row[:mobile],
          #address?
          :cf_campus => row[:campus],
          :cf_course_1 => row[:course],
          :cf_church_affiliation => row[:cf_church_affiliation]
         )
        contact.business_address = Address.new
        contact.business_address.street1 = row[:address]
        contact.business_address.city = row[:suburb]
        contact.business_address.state = row[:state]
        contact.business_address.zipcode = row[:pcode]
        contact.business_address.country = "Australia"
        contact.business_address.address_type = "Business"   
        
        contact.assigned_to = 3 #dave
        contact.account = Account.find_or_create_by_name(row[:campus])
        contact.account.user = User.find(1)
        
        contact.save
        
        puts "Added #{contact.name} to #{row[:campus]}"

      end
      
      puts
    end
  end
end
