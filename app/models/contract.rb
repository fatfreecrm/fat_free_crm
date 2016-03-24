# Table name: contracts
#
# id                 :integer       Primary key
# name               :string        Bronze, Silver, Gold, Platinum

class Contract < ActiveRecord::Base
  has_many :kiosks
end
