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
# Schema version: 27
#
# Table name: settings
#
#  id            :integer(4)      not null, primary key
#  name          :string(32)      default(""), not null
#  value         :text
#  default_value :text
#  created_at    :datetime
#  updated_at    :datetime
#
class Setting < ActiveRecord::Base

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
    return nil unless table_exists?
    return cached_settings[name.to_s] if cached_settings.has_key?(name.to_s)
    cached_settings[name.to_s] = if (setting = self.find_by_name(name.to_s))
      Marshal.load(Base64.decode64(setting.value || setting.default_value))
    end
  end

  #-------------------------------------------------------------------
  def self.[]= (name, value)
    return nil unless table_exists?
    setting = self.find_by_name(name.to_s) || self.new(:name => name.to_s)
    setting.value = Base64.encode64(Marshal.dump(value))
    setting.save
    cached_settings[name.to_s] = value
  end

  # Unrolls [ :one, :two ] settings array into [[ "One", :one ], [ "Two", :two ]]
  # picking symbol translations from locale. If setting is not a symbol but
  # string it gets copied without translation.
  #-------------------------------------------------------------------
  def self.unroll(setting)
    send(setting).map { |key| [ key.is_a?(Symbol) ? I18n.t(key) : key, key.to_sym ] }
  end

  def self.cached_settings
    @@cached_settings ||= {}
  end

  def self.table_exists?
    # Returns false if table or database is unavailable.
    super rescue false
  end
end



