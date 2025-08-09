# frozen_string_literal: true

class CreatePreferences < ActiveRecord::Migration[4.2]
  def self.up
    create_table :preferences do |t|
      t.references :user
      t.string :name, limit: 32, null: false, default: ""
      t.text :value
      t.timestamps
    end
    add_index :preferences, %i[user_id name]
  end

  def self.down
    drop_table :preferences
  end
end
