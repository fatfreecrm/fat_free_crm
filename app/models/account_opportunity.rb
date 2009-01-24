# == Schema Information
# Schema version: 15
#
# Table name: account_opportunities
#
#  id             :integer(4)      not null, primary key
#  account_id     :integer(4)
#  opportunity_id :integer(4)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class AccountOpportunity < ActiveRecord::Base
  belongs_to :account
  belongs_to :opportunity
  validates_presence_of :account_id, :opportunity_id

  acts_as_paranoid
end
