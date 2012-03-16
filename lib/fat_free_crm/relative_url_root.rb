#
# Set relative url root for FatFreeCRM::(Application | Engine), if required.

if Setting.base_url.present?
  FatFreeCRM.application.config.action_controller.relative_url_root = Setting.base_url
end

