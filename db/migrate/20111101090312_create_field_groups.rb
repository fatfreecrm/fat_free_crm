class CreateFieldGroups < ActiveRecord::Migration
  def self.up
    create_table :field_groups do |t|
      t.string      :klass_name,  :limit => 32
      t.string      :label,       :limit => 64
      t.integer     :position
      t.string      :tooltip
      t.timestamps
    end
  end

  def self.down
  end
end
