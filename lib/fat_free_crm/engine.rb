# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'rails-i18n'
require 'devise'
require 'devise-i18n'
require 'ransack'
require 'ransack/adapters'
require 'haml'
require 'responders'
require 'active_model_serializers'
require 'activemodel-serializers-xml'
require 'will_paginate'
require 'will_paginate/array'
require 'rails_autolink'
require 'jquery-rails'
require 'jquery-migrate-rails'
require 'jquery-ui-rails'
require 'select2-rails'
require 'responds_to_parent'
require 'dynamic_form'
require 'simple_form'
require 'country_select'

require 'fat_free_crm/callback'
require 'fat_free_crm/custom_fields'
require 'fat_free_crm/gem_ext'
require 'fat_free_crm/exceptions'
require 'fat_free_crm/fields'
require 'fat_free_crm/i18n'
require 'fat_free_crm/permissions'
require 'fat_free_crm/comment_extensions'
require 'fat_free_crm/errors'
require 'fat_free_crm/exportable'
require 'fat_free_crm/gravatar_image_tag'
require 'fat_free_crm/renderers'
require 'fat_free_crm/tabs'
require 'fat_free_crm/sortable'
require 'fat_free_crm/core_ext'
require 'fat_free_crm/view_factory'

module FatFreeCrm
  class Engine < ::Rails::Engine
    isolate_namespace FatFreeCrm
    
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters format: [:json] if respond_to?(:wrap_parameters)
    end
    
    # To enable root element in JSON for ActiveRecord objects.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = true
    end

    config.after_initialize do
      ActionView::Base.include FatFreeCrm::Callback::Helper
      ActionController::Base.include FatFreeCrm::Callback::Helper
      
      if Setting.database_and_table_exists?
        setting_files = [FatFreeCrm::Engine.root.join("config", "settings.default.yml")]
        setting_files << FatFreeCrm::Engine.root.join("config", "settings.yml") unless Rails.env == 'test'
        setting_files << Rails.root.join("config", "settings.yml") unless Rails.env == 'test'
        setting_files.each do |settings_file|
          Setting.load_settings_from_yaml(settings_file) if File.exist?(settings_file)
        end

        ::I18n.default_locale = Setting.locale
        ::I18n.fallbacks[:en] = [:"en-US"]
        ::I18n.backend.load_translations
    
        translations = { ransack: { attributes: {} } }
        FatFreeCrm::CustomField.find_each do |custom_field|
          if custom_field.field_group.present?
            model_key = custom_field.klass.model_name.singular
            translations[:ransack][:attributes][model_key] ||= {}
            translations[:ransack][:attributes][model_key][custom_field.name] = custom_field.label
          end
        end
    
#        I18n.backend.store_translations(Setting.locale.to_sym, translations)
      end
    
    end
  end
end
