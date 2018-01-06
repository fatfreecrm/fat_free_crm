# frozen_string_literal: true

class AddUserIdToLists < ActiveRecord::Migration[4.2]
  def change
    add_column :lists, :user_id, :integer, default: nil
    add_index :lists, :user_id
  end
end
