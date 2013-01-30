class CreateContactGroupsTable < ActiveRecord::Migration
  def change
		create_table :contact_groups, :force => true do |t|
		  t.string :uuid, :limit => 36
      t.references :user
      t.integer :assigned_to
      t.string :name, :limit => 64, :null => false, :default => ""
      t.string :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      t.string :category, :limit => 32
      t.datetime    :deleted_at
		  t.timestamps
		end
		  
		  add_index :contact_groups, [:user_id, :name, :deleted_at], :unique => true
		  add_index :contact_groups, :assigned_to
		
		create_table :contact_groups_contacts, :id => false do |t|
		  t.references :contact
		  t.references :contact_group
		end
		
		add_index :contact_groups_contacts, :contact_id
		add_index :contact_groups_contacts, :contact_group_id
		add_index :contact_groups_contacts, [:contact_id, :contact_group_id]
		
  end
end
