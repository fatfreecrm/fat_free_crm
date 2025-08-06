# frozen_string_literal: true

class RemoveSkypeFromUsersContactsAndLeads < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :users, :skype
    remove_column :contacts, :skype
    remove_column :leads, :skype
  end

  def self.down
    add_column :users, :skype, :string, limit: 32
    add_column :contacts, :skype, :string, limit: 128
    add_column :leads, :skype, :string, limit: 128
  end
end
