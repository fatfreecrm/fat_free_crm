class MailchimpObserver < ActiveRecord::Observer
  observe :contact

  def after_create(contact) 
    if contact.has_mailchimp_subscription?
      contact.cf_weekly_emails.reject(&:blank?).each do |list|
        self.delay.add_or_update_chimp(contact, list.gsub(/\s+/, "").underscore) #:city_east, :adelaide ...
      end
    end
  end

  def after_update(contact)
    if contact.cf_weekly_emails_changed? || contact.email_changed? || contact.first_name_changed? || contact.last_name_changed?
      mailchimp_lists(contact)
    end
  end
  
  def after_destroy(contact)
    contact.cf_weekly_emails.reject(&:blank?).each do |e|
      self.delay.delete_chimp(contact, e.gsub(/\s+/, "").underscore)
    end
  end

  private

  def mailchimp_lists(contact)
    unsubscribed_weekly = contact.cf_weekly_emails_was - contact.cf_weekly_emails # ["Adelaide", "City East"] - ["Adelaide"] => ["City East"]
    
    if contact.email_changed? || contact.first_name_changed? || contact.last_name_changed?
      subscribed_weekly = contact.cf_weekly_emails #add/update all
    else
      subscribed_weekly = contact.cf_weekly_emails - contact.cf_weekly_emails_was #just add to new lists
    end
    
    email_was = contact.email_changed? ? contact.email_was : nil
    
    unsubscribed_weekly.reject(&:blank?).each do |list|
      self.delay.delete_chimp(contact, list.gsub(/\s+/, "").underscore, email_was)
    end
    subscribed_weekly.reject(&:blank?).each do |list|
      self.delay.add_or_update_chimp(contact, list.gsub(/\s+/, "").underscore, email_was) #:city_east, :adelaide ...
    end
  end
  
  def add_or_update_chimp(contact, list, email_was = nil)
    list_id = Setting.mailchimp["#{list}_list_id"]
    list_key = Setting.mailchimp["#{list}_api_key"]
    original_email = email_was.nil? ? contact.email : email_was
    
    api = Mailchimp::API.new(list_key, :throws_exceptions => true)
    member_search = api.list_member_info({:id => list_id, :email_address => original_email})
    new_chimp_contact = (member_search["success"] == 0)

    c_hash = {
      :id => list_id,
      :email_address => original_email,
      :merge_vars => 
        Hash.new.tap do |merge_hash|
          #merge_hash["EMAIL"] = original_email
          merge_hash["EMAIL"] = contact.email
          #merge_hash["GROUPINGS"] = [{:name => "Interested in...", :groups => grouping.join(", ")}] unless (grouping == [])
          merge_hash["OPTIN_IP"] = Setting.network[:public_ip] if new_chimp_contact # or public_ip... => see network_helper.rb
          merge_hash["OPTIN_TIME"] = Time.now if new_chimp_contact
          merge_hash["FNAME"] = contact.first_name
          merge_hash["LNAME"] = contact.last_name
          merge_hash["GENDER"] = contact.cf_gender
        end 
    }
    
    if new_chimp_contact
      c_hash[:double_optin] = false
      r = api.list_subscribe(c_hash)
      t = "Added"
    else
      c_hash[:email_address] = member_search["data"][0]["id"]
      r = api.list_update_member(c_hash)
      t = "Updated"
    end
    Delayed::Worker.logger.add(Logger::INFO, "#{Time.now}: #{t} #{contact.first_name} #{contact.last_name} to list #{list}. Mailchimp responded: #{r}")
  end
  
  def delete_chimp(contact, list, email_was = nil)
    list_id = Setting.mailchimp["#{list}_list_id"]
    list_key = Setting.mailchimp["#{list}_api_key"]
    original_email = email_was.nil? ? contact.email : email_was
    
    api = Mailchimp::API.new(list_key, :throws_exceptions => true)
    
    r = api.list_unsubscribe({
      :id => list_id,
      :email_address => original_email,
      :delete_member => true,
      :send_goodbye => false
    })
    Delayed::Worker.logger.add(Logger::INFO, "#{Time.now}: Deleted #{contact.first_name} #{contact.last_name} from list #{list}. Mailchimp responded: #{r}")
    
  end
  
end