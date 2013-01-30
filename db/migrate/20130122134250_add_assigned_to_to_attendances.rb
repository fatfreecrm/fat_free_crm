class AddAssignedToToAttendances < ActiveRecord::Migration
  def up
    add_column :attendances, :assigned_to, :integer
    add_column :attendances, :user_id, :integer
    add_column :attendances, :access, :string, :default => "Public"
  end
  
  def down
    remove_column :attendances, :assigned_to
    remove_column :attendances, :user_id
    remove_column :attendances, :access
    
  end
end
