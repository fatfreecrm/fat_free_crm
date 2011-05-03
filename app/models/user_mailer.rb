class UserMailer < ActionMailer::Base
  
  def assigned_to_account_notification(account)
    subject "You have been assigned #{account.name} Account in CRM"
    from "CRM <crm@unboxedconsulting.com>"
    reply_to "#{account.user.email}"
    recipients "#{account.assignee.email}"
    body :account_url => account_url(account.id, :protocol => 'https', :host => "crm.unboxedconsulting.com"),
         :assigner => account.user.full_name,
         :account => account.name
  end

end