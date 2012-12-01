# Configure ActionMailer unless running tests

unless Rails.env.test?
  # Set SMTP settings if present.
  smtp_settings = Setting.smtp || {}
  if smtp_settings["address"].present?
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = smtp_settings.symbolize_keys
  end
end

# Set default host for outgoing emails
if Setting.host.present?
  (ActionMailer::Base.default_url_options ||= {})[:host] = Setting.host
end
