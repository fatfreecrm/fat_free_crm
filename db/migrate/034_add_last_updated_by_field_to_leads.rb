class AddLastUpdatedByFieldToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :last_updated_by, :integer
  end

  def self.down
    remove_column :leads, :last_updated_by
  end
end
