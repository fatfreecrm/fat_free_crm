# == Schema Information
# Schema version: 14
#
# Table name: account_contacts
#
#  id         :integer(4)      not null, primary key
#  account_id :integer(4)
#  contact_id :integer(4)
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class AccountContact < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact
  validates_presence_of :account_id, :contact_id
  validates_uniqueness_of :contact_id, :scope => :account_id, :message => "^The account already has this contact."
  acts_as_paranoid
end
