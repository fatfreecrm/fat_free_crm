require Rails.root.join('config', 'environments', 'production')

FatFreeCRM::Application.configure do
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = false

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Full error reports
  config.consider_all_requests_local = true
end
