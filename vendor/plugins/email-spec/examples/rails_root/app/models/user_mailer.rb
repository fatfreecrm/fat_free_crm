class UserMailer < ActionMailer::Base
  default_url_options = {:host => 'example.com'}
  def signup(email, name)
    @recipients  = email
    @from        = "admin@example.com"
    @subject     = "Account confirmation"
    @sent_on     = Time.now
    @body[:name] = name
  end

  def newsletter(email, name)
    @recipients  = email
    @from        = "admin@example.com"
    @subject     = "Newsletter sent"
    @sent_on     = Time.now
    @body[:name] = name
  end

  def attachments(email, name)
    @recipients  = email
    @from        = "admin@example.com"
    @subject     = "Attachments test"
    @sent_on     = Time.now
    @body[:name] = name
    add_attachment 'image.png'
    add_attachment 'document.pdf'
  end

  private

  def add_attachment(attachment_name)
    content_type 'multipart/mixed'
    attachment_path = File.join(RAILS_ROOT, 'attachments', attachment_name)
    File.open(attachment_path) do |file|
      filename = File.basename(file.path)
      attachment :filename => filename, :content_type => File.mime_type?(file), :body => file.read
    end
  end
end
