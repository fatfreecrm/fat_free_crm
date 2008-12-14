# == Schema Information
# Schema version: 10
#
# Table name: leads
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Lead < ActiveRecord::Base
  belongs_to :user
end
