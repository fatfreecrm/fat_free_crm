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

class Admin::ImportsController < Admin::ApplicationController
  before_filter "set_current_tab('admin/imports')", :only => [ :index ]

  # GET /admin/plugins
  # GET /admin/plugins.xml
  #----------------------------------------------------------------------------
  def index
    @plugins = FatFreeCRM::Plugin.list

    respond_with(@plugins)
  end
  
  def import
    @imports = Contact.new
    contacts = []
    
    CSV.foreach(params[:imports][:attached_file].tempfile.path, {:col_sep => ',', :headers => :first_row, :header_converters => :symbol}) do |row|

      contact_hash = Hash.new.tap do |h|
        #h[:email] = row[:email] 
        h[:user_id] = @current_user.id
        h[:access] = Setting.default_access
        h[:assigned_to] = nil
        h[:first_name] = row[:first_name]
        h[:last_name] = row[:last_name]
        h[:cf_gender] = row[:gender]
        h[:cf_student_number] = row[:student_number]
        h[:cf_member] = !row[:member].blank?
        h[:cf_year_commenced] = row[:year_commenced]
        h[:phone] = row[:phone]
        h[:mobile] = row[:mobile].gsub(/[\(\) ]/, "") unless row[:mobile].blank?
        #address?
        h[:email] = row[:email_1]
        h[:alt_email] = row[:email_2]
        h[:cf_campus] = row[:campus]
        h[:cf_faculty] = row[:faculty]
        h[:cf_course_1] = row[:course_1]
        h[:cf_course_2] = row[:course_2]
        h[:cf_church_affiliation] = row[:church_affiliation]
      end
      contact = Contact.find_or_initialize_by_email_and_last_name(row[:email_1], row[:last_name])
      contact.attributes = contact_hash
      contact.business_address = Address.new
      contact.business_address.street1 = row[:address]
      contact.business_address.city = row[:suburb]
      contact.business_address.state = row[:state]
      contact.business_address.zipcode = row[:pcode]
      contact.business_address.country = "Australia"
      contact.business_address.address_type = "Business"   
      
      user = User.first #make sure some user is set by default
      
      case row[:campus]
      when "City East" || "City West"
        user = User.find_by_first_name("dave")
      when "Adelaide"
        if row[:gender] == "Male"
          user = User.find_by_first_name("reuben")
        else
          user = User.find_by_first_name("laura")
        end
      when "Roseworthy"
        user = User.find_by_first_name("geoff")
      end
      
      contact.assigned_to = user.id
      contact.account = Account.find_or_create_by_name(row[:campus])
      contact.account.user = @current_user
      

      contacts << contact
      logger.debug "Added #{contact.name} to #{contact.account.name}"

    end
    

    contacts.each do |c|
      c.errors.each {|attr, err| @imports.errors.add attr, "#{c.first_name} #{c.last_name}: #{err}"} unless c.save
    end
    if @imports.errors.empty?
      flash[:notice] = "Imported #{contacts.count} contacts"
    else
      flash[:notice] = "There are errors in the file you are tying to import. No contacts imported"
    end
    
    render :index
  end
  
  def import_supporters
    @imports = Contact.new
    contacts = []
    
    CSV.foreach(params[:imports][:attached_supporters_file].tempfile.path, {:col_sep => ',', :headers => :first_row, :header_converters => :symbol}) do |row|
      
      contact_hash = Hash.new.tap do |h|
        #h[:email] = row[:email] 
        h[:user_id] = @current_user.id
        h[:access] = Setting.default_access
        h[:assigned_to] = nil
        h[:first_name] = row[:first_name]
        h[:last_name] = row[:last_name]
        h[:background_info] = row[:comments]
        h[:background_info] = row[:comments].blank? ? "Spouse name => #{row[:spouse_name]}" : "#{row[:comments]}\nSpouse name => #{row[:spouse_name]}" unless row[:spouse_name].blank?
        h[:phone] = row[:home_phone].to_s
        h[:phone] += "#{row[:work_phone]} [work]" unless row[:home_phone].blank?
        h[:cf_year_graduated] = row[:graduated]
        h[:cf_year_starting_work] = row[:starting_work]
        h[:mobile] = row[:mobile] #.gsub(/[\(\) ]/, "") unless row[:mobile].blank?
        #address?
        h[:email] = row[:email_address]
        h[:cf_church_affiliation] = row[:church]
        h[:cf_mailing_first_name] = row[:mailing_first_name]
        
        
      end
      contact = Contact.find_or_initialize_by_email_and_last_name(row[:email_address], row[:last_name])
      contact.attributes = contact_hash
      
      #Mailchimp address format is one field with double-space separating addr/suburb/state/pcode
      address = row[:address].split("  ") if !row[:address].blank?
      
      unless address.nil?
        contact.business_address = Address.new
        contact.business_address.street1 = address[0]
        contact.business_address.city = address[1]
        contact.business_address.state = address[2]
        contact.business_address.zipcode = address[3]
        contact.business_address.country = "Australia"
        contact.business_address.address_type = "Business"
      end   
      
      subscriptions = row[:interested_in].split(", ")
      contact.cf_supporter_emails << "TT Email" if (row[:interested_in].include?("Terrace Times Email") && !contact.cf_supporter_emails.include?("TT Email"))
      contact.cf_supporter_emails << "TT Mail" if (row[:interested_in].include?("Terrace Times Mail") && !contact.cf_supporter_emails.include?("TT Mail"))
      contact.cf_supporter_emails << "Prayer Points" if (row[:interested_in].include?("Prayer Points Email") && !contact.cf_supporter_emails.include?("Prayer Points"))
      
      contact.assigned_to = User.find_by_first_name("geoff").id
      contact.account = Account.find_or_create_by_name("Supporters") if contact.account.nil?
      contact.account.user = @current_user
      

      contacts << contact
      logger.debug "Added #{contact.name} to Supporters"

    end
    

    contacts.each do |c|
      c.errors.each {|attr, err| @imports.errors.add attr, "#{c.first_name} #{c.last_name}: #{err}"} unless c.save
    end
    if @imports.errors.empty?
      flash[:notice] = "Imported #{contacts.count} contacts"
    else
      flash[:notice] = "There are errors in the file you are tying to import. No contacts imported"
    end
    
    render :index
  end
  
  
end

