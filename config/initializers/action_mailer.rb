#
# Configure ActionMailer unless running tests
#   ActionMailer is setup in test mode later on
#
unless Rails.env.test?

  smtp_settings = Setting.smtp || {}

  if smtp_settings["address"].present?
    Rails.application.config.action_mailer.smtp_settings = smtp_settings.symbolize_keys
  end

  if (host = Setting.host).present?
    (Rails.application.routes.default_url_options ||= {})[:host] = host.gsub('http://', '')
  end

end
