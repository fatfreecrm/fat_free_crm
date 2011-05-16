class RemoveLastUpdatedByFromContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :last_updated_by 
  end

  def self.down
    add_column :contacts, :last_updated_by, :integer
  end
end
