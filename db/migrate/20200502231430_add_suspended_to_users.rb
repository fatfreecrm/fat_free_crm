# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030619)

class AddSuspendedToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_users, :suspended_at, :datetime
    rename_column :fat_free_crm_accounts, :tall_free_phone, :toll_free_phone
  end

  def self.down
    rename_column :fat_free_crm_accounts, :toll_free_phone, :tall_free_phone
    remove_column :fat_free_crm_users, :suspended_at
  end
end
