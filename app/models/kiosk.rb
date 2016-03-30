# Table name: kiosks
#
# id                    :integer       Primary key
# name                  :string        Livelink70797, index
# purchase_date         :date
# contract              :reference     bronze silver gold platinum, key
# contract_length       :integer       1, 12 (months)
# password              :string        livelink380
# cd_password           :string        poster
# notes                 :text          this kiosk has a custom .....
# account_id            :reference     account the kiosk is linked too, key

class Kiosk < ActiveRecord::Base
  before_save { self.name.capitalize! }
  belongs_to :account
  belongs_to :contract
  validates :name, uniqueness: true
  validate :account_id
  validate :contract_id
end
