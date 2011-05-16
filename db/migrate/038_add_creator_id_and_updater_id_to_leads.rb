class AddCreatorIdAndUpdaterIdToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :creator_id, :integer
    add_column :leads, :updater_id, :integer
  end

  def self.down
    remove_column :leads, :updater_id
    remove_column :leads, :creator_id
  end
end
