# == Schema Information
# Schema version: 17
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
