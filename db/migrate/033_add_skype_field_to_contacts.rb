class AddSkypeFieldToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :skype, :string, :limit => 64
  end

  def self.down
    remove_column :contacts, :skype
  end
end
