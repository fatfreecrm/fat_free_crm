class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks, :force => true do |t|
      t.string      :uuid, :limit => 36
      t.references  :user
      t.integer     :assigned_to
      t.integer     :completed_by
      t.string      :name, :null => false, :default => ""
      t.references  :asset, :polymorphic => true
      t.string      :priority, :limit => 32
      t.string      :category, :limit => 32
      t.string      :bucket, :limit => 32
      t.datetime    :due_at
      t.datetime    :completed_at
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :tasks, [ :user_id, :name, :deleted_at ], :unique => true
    add_index :tasks, :assigned_to
  end

  def self.down
    drop_table :tasks
  end
end
