# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20141126031837)

class IncreaseEmailTo254Chars < ActiveRecord::Migration[4.2]
  def up
    change_column :fat_free_crm_accounts, :email, :string, limit: 254
    change_column :fat_free_crm_contacts, :email, :string, limit: 254
    change_column :fat_free_crm_contacts, :alt_email, :string, limit: 254
    change_column :fat_free_crm_leads, :email, :string, limit: 254
    change_column :fat_free_crm_leads, :alt_email, :string, limit: 254
    change_column :fat_free_crm_users, :email, :string, limit: 254
    change_column :fat_free_crm_users, :alt_email, :string, limit: 254
  end

  def down
    change_column :fat_free_crm_accounts, :email, :string, limit: 64
    change_column :fat_free_crm_contacts, :email, :string, limit: 64
    change_column :fat_free_crm_contacts, :alt_email, :string, limit: 64
    change_column :fat_free_crm_leads, :email, :string, limit: 64
    change_column :fat_free_crm_leads, :alt_email, :string, limit: 64
    change_column :fat_free_crm_users, :email, :string, limit: 64
    change_column :fat_free_crm_users, :alt_email, :string, limit: 64
  end
end
