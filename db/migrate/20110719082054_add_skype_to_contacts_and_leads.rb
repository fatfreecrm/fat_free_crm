# frozen_string_literal: true

class AddSkypeToContactsAndLeads < ActiveRecord::Migration[4.2]
  def self.up
    add_column :contacts, :skype, :string, limit: 128
    add_column :leads, :skype, :string, limit: 128
  end

  def self.down
    remove_column :contacts, :skype
    remove_column :leads, :skype
  end
end
