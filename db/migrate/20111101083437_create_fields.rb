# frozen_string_literal: true

class CreateFields < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fields, force: true do |t|
      t.string :type
      t.references :field_group
      t.string :klass_name,  limit: 32
      t.integer :position
      t.string :name,        limit: 64
      t.string :label,       limit: 128
      t.string :hint
      t.string :placeholder
      t.string :as,          limit: 32
      t.string :collection
      t.boolean :disabled
      t.boolean :required
      t.integer :maxlength,   limit: 4
      t.timestamps
    end
    add_index :fields, :name
    add_index :fields, :klass_name
    add_index :fields, :field_group_id
  end

  def self.down
    drop_table :fields
  end
end
