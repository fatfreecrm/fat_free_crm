class CreateFields < ActiveRecord::Migration
  def self.up
    create_table :fields, :force => true do |t|
      t.string      :type
      t.references  :field_group
      t.integer     :position
      t.string      :name,        :limit => 64
      t.string      :label,       :limit => 64
      t.string      :hint
      t.string      :placeholder
      t.string      :as,          :limit => 32
      t.string      :collection
      t.boolean     :disabled
      t.boolean     :required
      t.integer     :maxlength,   :limit => 4
      t.timestamps
    end
    add_index :fields, :name
  end

  def self.down
    drop_table :fields
  end
end
