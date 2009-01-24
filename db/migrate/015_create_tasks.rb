class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks, :force => true do |t|
      t.string      :uuid, :limit => 36
      t.references  :user
      t.integer     :assigned_to
      t.string      :name, :null => false, :default => ""
      t.references  :asset, :polymorphic => true
      t.string      :priority, :limit => 32
      t.string      :status,   :limit => 32
      t.datetime    :due_at
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :tasks, [ :user_id, :name, :deleted_at ], :unique => true
    add_index :tasks, :assigned_to

    if adapter_name.downcase == "mysql"
      if select_value("SELECT VERSION()").to_i >= 5
        add_index :tasks, :uuid
        execute("CREATE TRIGGER tasks_uuid BEFORE INSERT ON tasks FOR EACH ROW SET NEW.uuid = UUID()")
      end
    end
  end

  def self.down
    drop_table :tasks
  end
end
