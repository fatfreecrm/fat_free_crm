class ChangeAttendanceBack < ActiveRecord::Migration
  def change
    rename_column :attendances, :event_id, :event_instance_id
    remove_index :attendances, :event_id
    remove_index :attendances, [:contact_id, :event_id]
    add_index :attendances, :event_instance_id
    add_index :attendances, [:contact_id, :event_instance_id]
  end
end
