# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

#
# Register and call when Setting class is loaded
# Load settings.default.yml
# Then override with settings.yml
# Don't override default settings in test environment
ActiveSupport.on_load(:fat_free_crm_setting) do
  setting_files = [FatFreeCRM.root.join("config", "settings.default.yml")]
  setting_files << Rails.root.join("config", "settings.yml") unless Rails.env == 'test'
  setting_files.each do |settings_file|
    Setting.load_settings_from_yaml(settings_file) if File.exist?(settings_file)
  end
end
