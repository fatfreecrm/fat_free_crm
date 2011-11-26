if Setting.table_exists? and Setting.host.present?
  (FatFreeCRM::Application.config.action_mailer.default_url_options ||= {})[:host] = Setting.host
end
