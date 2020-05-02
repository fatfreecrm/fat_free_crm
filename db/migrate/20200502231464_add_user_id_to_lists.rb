# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20131207033244)

class AddUserIdToLists < ActiveRecord::Migration[4.2]
  def change
    add_column :fat_free_crm_lists, :user_id, :integer, default: nil
    add_index :fat_free_crm_lists, :user_id
  end
end
