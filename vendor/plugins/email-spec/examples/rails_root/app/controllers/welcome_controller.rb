class WelcomeController < ApplicationController
  def signup
    UserMailer.deliver_signup(params['Email'], params['Name'])
  end

  def confirm
  end

  def newsletter
    UserMailer.send_later(:deliver_newsletter, params['Email'], params['Name'])
  end

  def attachments
    UserMailer.deliver_attachments(params['Email'], params['Name'])
  end
end
