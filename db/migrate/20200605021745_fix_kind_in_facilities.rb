class FixKindInFacilities < ActiveRecord::Migration[6.0]
  def up
    change_column :fat_free_crm_facilities, :facility_kind, :string
    FatFreeCrm::Facility.reset_column_information
    FatFreeCrm::Facility.all.each do |f|
      f.update_attribute :facility_kind, f.facility_kind.match(/"(?<name>[^\\]*)"/)[:name]
    end
  end

  def down
  end
end
