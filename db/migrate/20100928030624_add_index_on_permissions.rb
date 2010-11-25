class AddIndexOnPermissions < ActiveRecord::Migration
  def self.up
    add_index :permissions, [ :asset_id, :asset_type ]
  end

  def self.down
    remove_index :permissions, [ :asset_id, :asset_type ]
  end
end
