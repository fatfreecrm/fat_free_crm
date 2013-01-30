class AddEventsTables < ActiveRecord::Migration
  def change
    create_table :events, :force => true do |t|
      t.string :uuid, :limit => 36
      t.references :user
      t.references :contact_group
      t.integer :assigned_to
      t.string :name, :limit => 64, :null => false, :default => ""
      t.text :subscribed_users
      t.string :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      t.string :category, :limit => 32
      t.datetime    :deleted_at
      t.timestamps
    end
      
      add_index :events, [:user_id, :name, :deleted_at], :unique => true
      add_index :events, :assigned_to
    
    create_table :event_instances do |t|
      t.references :event
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
       
    create_table :attendances, :id => false do |t|
      t.references :contact
      t.references :event_instance
    end
    
    add_index :attendances, :contact_id
    add_index :attendances, :event_instance_id
    add_index :attendances, [:contact_id, :event_instance_id]
    
  end
end
