# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: settings
#
#  id            :integer         not null, primary key
#  name          :string(32)      default(""), not null
#  value         :text
#  created_at    :datetime
#  updated_at    :datetime
#

# Fat Free CRM settings are stored in three places, and are loaded in the following order:
#
# 1) config/settings.default.yml
# 2) config/settings.yml  (if exists)
# 3) 'settings' table in database  (if exists)
#
# Any configured settings in `config/settings.yml` will override those in
# `config/settings.default.yml`, and settings in the database table have the highest priority.

class Setting < ActiveRecord::Base
  serialize :value

  # Use class variables for cache and yaml settings.
  cattr_accessor :cache, :yaml_settings
  @@cache = @@yaml_settings = {}.with_indifferent_access

  class << self
    # Cache should be cleared before each request.
    def clear_cache!
      @@cache = {}.with_indifferent_access
    end

    #-------------------------------------------------------------------
    def method_missing(method, *args)
      super
    rescue NoMethodError
      method_name = method.to_s
      if method_name.last == "="
        self[method_name.sub("=", "")] = args.first
      else
        self[method_name]
      end
    end

    # Get setting value (from database or loaded YAML files)
    #-------------------------------------------------------------------
    def [](name)
      # Return value if cached
      return cache[name] if cache.key?(name)
      # Check database
      if database_and_table_exists?
        if setting = find_by_name(name.to_s)
          return cache[name] = setting.value unless setting.value.nil?
        end
      end
      # Check YAML settings
      return cache[name] = yaml_settings[name] if yaml_settings.key?(name)
    end

    # Set setting value
    #-------------------------------------------------------------------
    def []=(name, value)
      return nil unless database_and_table_exists?
      setting = find_by_name(name.to_s) || new(name: name)
      setting.value = value
      setting.save
      cache[name] = value
    end

    # Unrolls [ :one, :two ] settings array into [[ "One", :one ], [ "Two", :two ]]
    # picking symbol translations from locale. If setting is not a symbol but
    # string it gets copied without translation.
    #-------------------------------------------------------------------
    def unroll(setting)
      send(setting).map { |key| [key.is_a?(Symbol) ? I18n.t(key) : key, key.to_sym] }
    end

    # Retrieves the value object corresponding to the each key objects repeatedly.
    # Equivalent to the #dig method on a Hash.
    #-------------------------------------------------------------------
    def dig(key, *rest)
      value = self[key]
      if value.nil? || rest.empty?
        value
      elsif value.respond_to?(:dig)
        value.dig(*rest)
      else
        raise TypeError, "#{value.class} does not have #dig method"
      end
    end

    def database_and_table_exists?
      # Returns false if table or database is unavailable.
      # Catches all database-related errors, so that Setting will return nil
      # instead of crashing the entire application.

      table_exists?
    rescue StandardError
      false
    end

    # Loads settings from YAML files
    def load_settings_from_yaml(file)
      settings = YAML.load(ERB.new(File.read(file)).result)
      @@yaml_settings.deep_merge!(settings)
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_setting, self)
end
