# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
