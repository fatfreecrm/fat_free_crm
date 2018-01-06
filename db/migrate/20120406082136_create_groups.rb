# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.timestamps
    end

    add_column :permissions, :group_id, :integer
    add_index :permissions, :group_id

    create_table :groups_users, id: false do |t|
      t.references :group
      t.references :user
    end
    add_index :groups_users, :group_id
    add_index :groups_users, :user_id
    add_index :groups_users, %i[group_id user_id]
  end
end
