class AddUserIdToLists < ActiveRecord::Migration
  def change
    add_column :lists, :user_id, :integer, default: nil
    add_index :lists, :user_id
  end
end
