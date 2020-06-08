module FatFreeCrm
  class Unit < ApplicationRecord
    belongs_to :unitable, polymorphic: true
    has_many :details
  end
end