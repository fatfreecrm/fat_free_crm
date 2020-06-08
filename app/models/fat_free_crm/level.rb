module FatFreeCrm
  class Level < ApplicationRecord
    belongs_to :facility
    has_many :sections
    has_many :zones
    has_many :units, as: :unitable
  end
end