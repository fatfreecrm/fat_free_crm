module FatFreeCrm
  class Assignment < ActiveRecord::Base
    belongs_to :facility, class_name: FatFreeCrm.facility_class
    belongs_to :contact

    def self.facility_class
      @@facility_class.constantize
    end
  end
end