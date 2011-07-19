class AddSkypeToContactsAndLeads < ActiveRecord::Migration
  def self.up
    add_column :contacts, :skype, :string, :limit => 128
    add_column :leads, :skype, :string, :limit => 128
  end

  def self.down
    remove_column :contacts, :skype
    remove_column :leads, :skype
  end
end

