# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCrm
  class Engine < ::Rails::Engine
    isolate_namespace FatFreeCrm

    config.after_initialize do
      if FatFreeCrm::Setting.database_and_table_exists?
        setting_files = [FatFreeCrm::Engine.root.join("config", "settings.default.yml")]
        setting_files << FatFreeCrm::Engine.root.join("config", "settings.yml") unless Rails.env == 'test'
        setting_files << Rails.root.join("config", "settings.yml") unless Rails.env == 'test'
        setting_files.each do |settings_file|
          FatFreeCrm::Setting.load_settings_from_yaml(settings_file) if File.exist?(settings_file)
        end

        I18n.backend.load_translations
    
        translations = { ransack: { attributes: {} } }
        FatFreeCrm::CustomField.find_each do |custom_field|
          if custom_field.field_group.present?
            model_key = custom_field.klass.model_name.singular
            translations[:ransack][:attributes][model_key] ||= {}
            translations[:ransack][:attributes][model_key][custom_field.name] = custom_field.label
          end
        end
    
        I18n.backend.store_translations(FatFreeCrm::Setting.locale.to_sym, translations)
      end
    
    end
  end
end