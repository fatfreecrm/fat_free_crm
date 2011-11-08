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
# Table name: preferences
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  name       :string(32)      default(""), not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#
class Preference < ActiveRecord::Base
  belongs_to :user

  #-------------------------------------------------------------------
  def [] (name)
    return super(name) if name.to_s == "user_id" # get the value of belongs_to

    preference = Preference.find_by_name_and_user_id(name.to_s, self.user.id)
    preference ? Marshal.load(Base64.decode64(preference.value)) : nil
  end

  #-------------------------------------------------------------------
  def []= (name, value)
    return super(name, value) if name.to_s == "user_id" # set the value of belongs_to

    encoded = Base64.encode64(Marshal.dump(value))
    preference = Preference.find_by_name_and_user_id(name.to_s, self.user.id)
    if preference
      preference.update_attribute(:value, encoded)
    else
      Preference.create(:user => self.user, :name => name.to_s, :value => encoded)
    end
    value
  end

end
