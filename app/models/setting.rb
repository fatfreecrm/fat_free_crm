require 'syck'

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
      begin
        super
      rescue NoMethodError
        method_name = method.to_s
        if method_name.last == "="
          self[method_name.sub("=", "")] = args.first
        else
          self[method_name]
        end
      end
    end

    # Get setting value (from database or loaded YAML files)
    #-------------------------------------------------------------------
    def [](name)
      # Return value if cached
      return cache[name] if cache.has_key?(name)
      # Check database
      if database_and_table_exists?
        if setting = self.find_by_name(name.to_s)
          unless setting.value.nil?
            return cache[name] = setting.value
          end
        end
      end
      # Check YAML settings
      if yaml_settings.has_key?(name)
        return cache[name] = yaml_settings[name]
      end
    end


    # Set setting value
    #-------------------------------------------------------------------
    def []=(name, value)
      return nil unless database_and_table_exists?
      setting = self.find_by_name(name.to_s) || self.new(:name => name)
      setting.value = value
      setting.save
      cache[name] = value
    end


    # Unrolls [ :one, :two ] settings array into [[ "One", :one ], [ "Two", :two ]]
    # picking symbol translations from locale. If setting is not a symbol but
    # string it gets copied without translation.
    #-------------------------------------------------------------------
    def unroll(setting)
      send(setting).map { |key| [ key.is_a?(Symbol) ? I18n.t(key) : key, key.to_sym ] }
    end

    def database_and_table_exists?
      # Returns false if table or database is unavailable.
      # Catches all database-related errors, so that Setting will return nil
      # instead of crashing the entire application.
      table_exists? rescue false
    end


    # Loads settings from YAML files
    def load_settings_from_yaml(file)
      begin
        #~ settings = YAML.load_file(file)
        settings = Syck.load_file(file)
        # Merge settings into current settings hash (recursively)
        @@yaml_settings.deep_merge!(settings)
      rescue Exception => ex
        puts "Settings couldn't be loaded from #{file}: #{ex.message}"
      end
      yaml_settings
    end
  end
end

#
# TODO: code smell - refactor loading of settings
# The following code should be in a lazy load hook or Settings class initializer
#

#
# We have fat_free_crm/syck_yaml which loads very early on in the bootstrap process
# However, something else (possibly bundler) is reverting back to Psych later on so
# we need to set it again here to ensure the files are read in the correct manner.
#
YAML::ENGINE.yamler = 'syck'

# Load default settings, then override with custom settings, if present.
setting_files = [FatFreeCRM.root.join("config", "settings.default.yml")]
# Don't override default settings in test environment
setting_files << Rails.root.join("config", "settings.yml") unless Rails.env == 'test'
setting_files.each do |settings_file|
  Setting.load_settings_from_yaml(settings_file) if File.exist?(settings_file)
end
