class AddCreatorIdAndUpdaterIdToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :creator_id, :integer
    add_column :contacts, :updater_id, :integer
  end

  def self.down
    remove_column :contacts, :updater_id
    remove_column :contacts, :creator_id
  end
end
