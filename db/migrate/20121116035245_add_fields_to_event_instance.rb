class AddFieldsToEventInstance < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.remove :location, :starts_at, :ends_at
    end
    change_table :event_instances do |t|
      t.string :location
      t.datetime :starts_at
      t.datetime :ends_at
    end
  end
end
