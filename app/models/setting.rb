# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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
# Schema version: 21
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
    setting = self.find_by_name(name.to_s)
    setting ? Marshal.load(Base64.decode64(setting.value || setting.default_value)) : nil
  end

  #-------------------------------------------------------------------
  def self.[]= (name, value)
    setting = self.find_by_name(name.to_s) || self.new(:name => name.to_s)
    setting.value = Base64.encode64(Marshal.dump(value))
    setting.save
  end

  #-------------------------------------------------------------------
  def self.as_hash(setting)
    send(setting).inject({}) { |hash, item| hash[item.last] = item.first; hash }
  end

  #-------------------------------------------------------------------
  def self.invert(setting)
    send(setting).invert.sort
  end

end
