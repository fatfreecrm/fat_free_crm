class AddCreatorIdAndUpdaterIdToOpportunities < ActiveRecord::Migration
  def self.up
    add_column :opportunities, :creator_id, :integer
    add_column :opportunities, :updater_id, :integer
  end

  def self.down
    remove_column :opportunities, :updater_id
    remove_column :opportunities, :creator_id
  end
end
