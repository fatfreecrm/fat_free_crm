class CreateFields < ActiveRecord::Migration
  def self.up
    create_table :fields, :force => true do |t|
      t.string      :type
      t.references  :field_group
      t.string      :field_type,  :limit => 32
      t.string      :name,        :limit => 64
      t.string      :label,       :limit => 64
      t.integer     :position
      t.string      :default
      t.string      :tooltip
      t.string      :options
      t.integer     :max_size,    :limit => 4
      t.boolean     :required
      t.boolean     :disabled
      t.timestamps
    end
    add_index :fields, :name
  end

  def self.down
    drop_table :fields
  end
end
