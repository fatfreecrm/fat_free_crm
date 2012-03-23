# Configure ActionMailer unless running tests

unless Rails.env.test?
  # Set SMTP settings if present.
  if smtp_settings = Setting.smtp
    Rails.application.config.action_mailer.delivery_method = :smtp
    Rails.application.config.action_mailer.smtp_settings = smtp_settings
  end
end

# Set default host for outgoing emails
if Setting.host.present?
  (Rails.application.config.action_mailer.default_url_options ||= {})[:host] = Setting.host
end
