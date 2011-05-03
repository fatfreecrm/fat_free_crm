class UserMailer < ActionMailer::Base
  
  def assigned_to_account_notification(account)
    subject "You have been assigned #{account.name} Account in CRM"
    from "CRM <crm@unboxedconsulting.com>"
    reply_to "#{account.user.email}"
    recipients "#{account.assignee.email}"
    body[:account] = account
  end

end