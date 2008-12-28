# == Schema Information
# Schema version: 11
#
# Table name: opportunities
#
#  id               :integer(4)      not null, primary key
#  uuid             :string(36)
#  user_id          :integer(4)
#  account_id       :integer(4)      not null
#  campaign_id      :integer(4)
#  name             :string(64)      default(""), not null
#  source           :string(32)
#  stage            :string(32)
#  probability      :integer(4)
#  amount           :decimal(12, 2)
#  expected_revenue :decimal(12, 2)
#  close_on         :date
#  deleted_at       :datetime
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#

class Opportunity < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  belongs_to :campaign
  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify the opportunity name."
  validates_uniqueness_of :name, :scope => :user_id
end
