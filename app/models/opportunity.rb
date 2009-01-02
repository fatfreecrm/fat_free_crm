# == Schema Information
# Schema version: 14
#
# Table name: opportunities
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  name        :string(64)      default(""), not null
#  source      :string(32)
#  stage       :string(32)
#  probability :integer(4)
#  amount      :decimal(12, 2)
#  closes_on   :date
#  notes       :text
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Opportunity < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  belongs_to :campaign
  has_many :contacts, :through => :contact_opportunities
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify the opportunity name."
  validates_uniqueness_of :name, :scope => :user_id

  #----------------------------------------------------------------------------
  def weighted_amount
    (amount * probability) / 100
  end

end
