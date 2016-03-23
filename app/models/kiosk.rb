# Table name: kiosks
#
# id                    :integer       Primary key, 70797
# name                  :string        livelink70797
# purchase_date         :date
# contract_type         :string        bronze, silver, gold, platinum
# contract_length       :integer       1, 12 (months)
# password              :string        livelink380
# cd_password           :string        poster
# notes                 :text          this kiosk has a custom .....
# account_id            :integer       account the kiosk is linked too

class Kiosk < ActiveRecord::Base

  belongs_to :account
  validates :name, uniqueness: true
  validate :account_id

end
