class UserMailer < ActionMailer::Base

  def assigned_to_account_email_notification(account)
    @resource_name = account.name
    assigned_to_resource_email_notification(account)
  end

  def assigned_to_lead_email_notification(lead)
    @resource_name = lead.full_name
    assigned_to_resource_email_notification(lead)
  end
  
  def assigned_to_opportunity_email_notification(opportunity)
    @resource_name = opportunity.name
    assigned_to_resource_email_notification(opportunity)
  end
  
  def assigned_to_contact_email_notification(contact)
    @resource_name = contact.full_name
    assigned_to_resource_email_notification(contact)
  end
  
  protected
  
  def assigned_to_resource_email_notification(resource)
    subject "You have been assigned #{@resource_name} #{resource.class.name} in CRM"
    from "CRM <#{AppConfig.admin_email_address}>"
    reply_to "#{resource.user.email}"
    recipients "#{resource.assignee.email}"
    body :resource_url => self.send("#{resource.class.name.downcase}_url".to_sym, resource.id, :protocol => 'https', :host => "crm.unboxedconsulting.com"),
         :assigner => resource.user.full_name,
         :resource => @resource_name,
         :resource_type => resource.class.name
    template :assigned_to_resource_email_notification
  end
end