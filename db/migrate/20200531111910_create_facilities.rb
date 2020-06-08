class CreateFacilities < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_facilities do |t|
      t.string :facility_kind, array: true
      t.string :lonlat, :st_point, geographic: true
      t.references :user
      t.integer :assigned_to
      t.string :access, limit: 8, default: "Public" # %w(Private Public Shared)
      t.integer :location_id

      t.timestamps
    end
  end
end
