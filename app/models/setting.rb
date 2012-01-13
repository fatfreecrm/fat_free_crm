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
#  default_value :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Setting < ActiveRecord::Base

  # Use a class variable as a cache. This is cleared before each request.
  def self.clear_cache!; @@cache = {}; end
  cattr_accessor :cache; @@cache = {}

  #-------------------------------------------------------------------
  def self.method_missing(method, *args)
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

  #-------------------------------------------------------------------
  def self.[] (name)
    return nil unless database_and_table_exists?
    k = name.to_s
    return cache[k] if cache.has_key?(k)
    if setting = self.find_by_name(k)
      value = Marshal.load(Base64.decode64(setting.value.nil? ? setting.default_value : setting.value))
      cache[k] = value
    end
  end

  #-------------------------------------------------------------------
  def self.[]= (name, value)
    return nil unless database_and_table_exists?
    k = name.to_s
    setting = self.find_by_name(k) || self.new(:name => k)
    setting.value = Base64.encode64(Marshal.dump(value))
    setting.save
    cache[k] = value
  end

  # Unrolls [ :one, :two ] settings array into [[ "One", :one ], [ "Two", :two ]]
  # picking symbol translations from locale. If setting is not a symbol but
  # string it gets copied without translation.
  #-------------------------------------------------------------------
  def self.unroll(setting)
    send(setting).map { |key| [ key.is_a?(Symbol) ? I18n.t(key) : key, key.to_sym ] }
  end

  def self.database_and_table_exists?
    # Returns false if table or database is unavailable.
    # Catches all database-related errors, so that Setting will return nil
    # instead of crashing the entire application.
    table_exists? rescue false
  end
end



