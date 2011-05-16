class RemoveLastUpdatedByFromLeads < ActiveRecord::Migration
  def self.up
    remove_column :leads, :last_updated_by 
  end

  def self.down
    add_column :leads, :last_updated_by, :integer
  end
end
