# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20101221345678)

class AddRatingAndCategoryToAccounts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_accounts, :rating, :integer, default: 0, null: false
    add_column :fat_free_crm_accounts, :category, :string, limit: 32
  end

  def self.down
    remove_column :fat_free_crm_accounts, :category
    remove_column :fat_free_crm_accounts, :rating
  end
end
