module FatFreeCrm
  class Zone < ApplicationRecord
    belongs_to :level
    has_many :units, as: :unitable
  end  
end