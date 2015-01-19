class CreateFieldGroups < ActiveRecord::Migration
  def self.up
    create_table :field_groups do |t|
      t.string :name,        limit: 64
      t.string :label,       limit: 128
      t.integer :position
      t.string :hint
      t.timestamps
    end
  end

  def self.down
    drop_table :field_groups
  end
end
