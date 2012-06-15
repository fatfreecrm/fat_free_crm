class AddBackgroundInfoToContactGroups < ActiveRecord::Migration
  def self.up
    add_column :contact_groups, :background_info, :string
    
  end

  def self.down
    remove_column :contact_groups, :background_info
    
  end
end
