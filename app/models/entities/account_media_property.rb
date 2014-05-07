class AccountMediaProperty < ActiveRecord::Base
  belongs_to :account
  attr_accessible :description, :media_type
end
