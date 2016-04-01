class AddIndexToKioskName < ActiveRecord::Migration
  def change
    add_index :kiosks, :name, unique: true
  end
end
