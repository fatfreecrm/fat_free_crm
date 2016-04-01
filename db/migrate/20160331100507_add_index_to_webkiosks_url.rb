class AddIndexToWebkiosksUrl < ActiveRecord::Migration
  def change
    add_index :webkiosks, :url, unique: true
  end
end
