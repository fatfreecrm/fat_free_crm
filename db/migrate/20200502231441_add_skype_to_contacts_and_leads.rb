# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20110719082054)

class AddSkypeToContactsAndLeads < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_contacts, :skype, :string, limit: 128
    add_column :fat_free_crm_leads, :skype, :string, limit: 128
  end

  def self.down
    remove_column :fat_free_crm_contacts, :skype
    remove_column :fat_free_crm_leads, :skype
  end
end
