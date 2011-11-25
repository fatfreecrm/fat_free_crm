if Setting.table_exists? and !Setting.mail_host.nil?
  Rails.application.config.action_mailer.default_url_options[:host] = Setting.mail_host
end
