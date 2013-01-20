class SaasuObserver < ActiveRecord::Observer
  observe :contact
  
  def after_create(contact) 
    self.delay.add_saasu(contact) if not_excluded?(contact)
  end
  
  def after_update(contact)

    if contact.saasu_uid.present? && contact.account.present? && excluded_accounts.include?(contact.account.id)
      # moved into an excluded account - time to delete from saasu
      self.delay.delete_saasu(contact.saasu_uid)
      self.saasu_uid = nil
      self.save!
      
    elsif not_excluded?(contact)
      if (contact.email_changed? || 
          contact.first_name_changed? || 
          contact.last_name_changed? || 
          contact.mobile_changed? || 
          contact.phone_changed?)
      
        begin  
          result = Saasu::Contact.find(contact.saasu_uid)
        rescue
          #Saasu::Contact.find errors out if not found...rescue is easier than rewriting the gem :)
          self.delay.add_saasu(contact)
        end
        if !result.last_updated_uid.nil?
          self.delay.update_saasu(contact, result.last_updated_uid)
        end
      end
    end
  end
  
  def after_destroy(contact)
    self.delay.delete_saasu(contact.saasu_uid) if contact.saasu_uid.present?
  end

  private
  
  def not_excluded?(contact)
    excluded = ["Supporters", "2012 Graduates"]
    excluded_accounts = Account.where('name IN (?)', excluded).collect{|a| a.id}
    
    Contact.includes(:account).where('contacts.id = ? AND accounts.id IN (?)', contact.id, excluded_accounts).empty?
  end

  def add_saasu(c)
    sc = Saasu::Contact.new
    sc.given_name = c.first_name
    sc.family_name = c.last_name
    sc.email_address = c.email
    sc.email = c.email
    sc.mobile_phone = c.mobile
    sc.main_phone = c.mobile
    sc.home_phone = c.phone
    response = Saasu::Contact.insert(sc)
    
    if response.errors.nil?
      c.saasu_uid = response.inserted_entity_uid
      Delayed::Worker.logger.add(Logger::INFO, "Added #{c.full_name} to saasu")
    else
      Delayed::Worker.logger.add(Logger::INFO, "Error adding #{c.full_name} to saasu. #{response.errors}")
    end
    
  end
  
  def update_saasu(c, updated_uid)
    sc = Saasu::Contact.new
    sc.given_name = c.first_name
    sc.family_name = c.last_name
    sc.email_address = c.email
    sc.email = c.email
    sc.mobile_phone = c.mobile
    sc.main_phone = c.mobile
    sc.home_phone = c.phone
    sc.uid = c.saasu_uid
    sc.last_updated_uid = updated_uid
    
    response = Saasu::Contact.update(sc)
    
    if response.errors.nil?
      Delayed::Worker.logger.add(Logger::INFO, "Updated #{c.full_name} to saasu")
    else
      Delayed::Worker.logger.add(Logger::INFO, "Error updating #{c.full_name} to saasu. #{response.errors}")
    end
  end
  
  def delete_saasu(saasu_uid)
    Saasu::Contact.delete(saasu_uid)
    
    Delayed::Worker.logger.add(Logger::INFO, "Deleted contact with saasu_uid #{saasu_uid}")
  end
  
end