require "fat_free_crm"

if Setting.host.present?
  (FatFreeCRM::Application.config.action_mailer.default_url_options ||= {})[:host] = Setting.host
end