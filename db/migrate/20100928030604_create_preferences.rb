class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.references :user
      t.string     :name, :limit => 32, :null => false, :default => ""
      t.text       :value
      t.timestamps
    end
    add_index :preferences, [ :user_id, :name ]
  end

  def self.down
    drop_table :preferences
  end
end
