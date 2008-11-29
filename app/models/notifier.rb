class Notifier < ActionMailer::Base
  
  default_url_options[:host] = "localhost:3000"
  
  #----------------------------------------------------------------------------
  def password_reset_instructions(user)
    subject       "Fat Free CRM: password reset instructions"
    from          "Fat Free CRM <noreply@fatfreecrm.com>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_url => edit_password_url(user.perishable_token)
  end

end
