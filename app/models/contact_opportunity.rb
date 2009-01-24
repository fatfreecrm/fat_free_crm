# == Schema Information
# Schema version: 15
#
# Table name: contact_opportunities
#
#  id             :integer(4)      not null, primary key
#  contact_id     :integer(4)
#  opportunity_id :integer(4)
#  role           :string(32)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class ContactOpportunity < ActiveRecord::Base
  belongs_to :contact
  belongs_to :opportunity
  validates_presence_of :contact_id, :opportunity_id

  acts_as_paranoid
end
