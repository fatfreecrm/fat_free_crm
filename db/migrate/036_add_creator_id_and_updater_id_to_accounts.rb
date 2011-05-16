class AddCreatorIdAndUpdaterIdToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :creator_id, :integer
    add_column :accounts, :updater_id, :integer
  end

  def self.down
    remove_column :accounts, :creator_id
    remove_column :accounts, :updater_id
  end
end
