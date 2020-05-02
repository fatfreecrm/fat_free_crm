# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030621)

class AddEmailToAccounts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_accounts, :email, :string, limit: 64
  end

  def self.down
    remove_column :fat_free_crm_accounts, :email
  end
end
