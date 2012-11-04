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
# Table name: preferences
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  name       :string(32)      default(""), not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

class Preference < ActiveRecord::Base
  belongs_to :user

  #-------------------------------------------------------------------
  def [] (name)
    # Following line is to preserve AR relationships
    return super(name) if name.to_s == "user_id" # get the value of belongs_to

    return cached_prefs[name.to_s] if cached_prefs.has_key?(name.to_s)
    cached_prefs[name.to_s] = if (self.user.present? && pref = Preference.find_by_name_and_user_id(name.to_s, self.user.id))
      Marshal.load(Base64.decode64(pref.value))
    end
  end

  #-------------------------------------------------------------------
  def []= (name, value)
    return super(name, value) if name.to_s == "user_id" # set the value of belongs_to

    encoded = Base64.encode64(Marshal.dump(value))
    if pref = Preference.find_by_name_and_user_id(name.to_s, self.user.id)
      pref.update_attribute(:value, encoded)
    else
      Preference.create(:user => self.user, :name => name.to_s, :value => encoded)
    end
    cached_prefs[name.to_s] = value
  end

  def cached_prefs
    @cached_prefs ||= {}
  end

end
