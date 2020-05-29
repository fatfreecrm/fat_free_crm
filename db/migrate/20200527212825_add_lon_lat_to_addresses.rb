class AddLonLatToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_addresses, :lonlat, :st_point, geographic: true
  end
end