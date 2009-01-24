# == Schema Information
# Schema version: 15
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
    if new_record? && name.to_s != "user_id"
      preference = Preference.find_by_name_and_user_id(name.to_s, self.user.id)
      preference ? Marshal.load(Base64.decode64(preference.value)) : nil
    else
      value = super(name)
      name.to_s == "value" ? Marshal.load(Base64.decode64(value)) : value
    end
  end

  #-------------------------------------------------------------------
  def []= (name, value)
    return super(name, value) if name.to_s == "user_id"
    if new_record?
      preference = Preference.find_by_name_and_user_id(name.to_s, self.user.id)
      preference.value = Base64.encode64(Marshal.dump(value))
      preference.save
    else
      super(name, Base64.encode64(Marshal.dump(value)))
      self.save
    end
    value
  end

end
