# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
        super(method, *args)
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
        if setting = self.find_by_name(name)
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
      setting = self.find_by_name(name) || self.new(:name => name)
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
    def load_settings_from_yaml
      @@yaml_settings = {}.with_indifferent_access

      setting_files = [
        FatFreeCRM.root.join("config", "settings.default.yml"),
        Rails.root.join("config", "settings.yml")
      ]

      # Load default settings, then override with custom settings
      setting_files.each do |file|
        if File.exist?(file)
          begin
            settings = YAML.load_file(file)
            # Merge settings into current settings hash (recursively)
            @@yaml_settings.deep_merge!(settings)
          rescue Exception => ex
            puts "Settings couldn't be loaded from #{file}: #{ex.message}"
          end
        end
      end
      yaml_settings
    end
  end
end


# Preload YAML settings as soon as class is loaded.
Setting.load_settings_from_yaml
