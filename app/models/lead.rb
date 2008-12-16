# == Schema Information
# Schema version: 10
#
# Table name: leads
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  salutation  :string(16)
#  first_name  :string(64)      default(""), not null
#  last_name   :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  company     :string(64)
#  title       :string(64)
#  source      :string(32)
#  status      :string(32)
#  rating      :integer(4)
#  referred_by :string(64)
#  website     :string(64)
#  email       :string(64)
#  phone       :string(32)
#  mobile      :string(32)
#  fax         :string(32)
#  address     :string(255)
#  do_not_call :boolean(1)      not null
#  notes       :text
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :permissions, :as => :asset, :include => :user
  acts_as_paranoid

  #----------------------------------------------------------------------------
  def full_name
    "#{self.salutation} #{self.first_name} #{self.last_name}"
  end

end
