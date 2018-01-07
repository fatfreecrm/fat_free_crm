# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :settings, force: true do |t|
      t.string :name, limit: 32, null: false, default: ""
      t.text :value
      t.text :default_value
      t.timestamps
    end
    add_index :settings, :name
  end

  def self.down
    drop_table :settings
  end
end
