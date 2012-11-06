class AddReferencesToEventInstances < ActiveRecord::Migration
  def change
    change_table :event_instances do |t|
      t.change :name, :string, {:limit => 64, :null => false, :default => ""}
      t.references :user
      t.integer :assigned_to
      t.text :subscribed_users
      t.string :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      
    end
  end
end
