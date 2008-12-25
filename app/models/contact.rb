# == Schema Information
# Schema version: 10
#
# Table name: contacts
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Contact < ActiveRecord::Base
  belongs_to :user
  uses_mysql_uuid
  
  def full_name
    "Full Name"
  end
end
