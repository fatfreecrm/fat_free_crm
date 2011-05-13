class AddLastUpdatedByFieldToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :last_updated_by, :integer
  end

  def self.down
    remove_column :contacts, :last_updated_by
  end
end
