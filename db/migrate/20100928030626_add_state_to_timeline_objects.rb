class AddStateToTimelineObjects < ActiveRecord::Migration
  def self.up
    add_column :comments, :state, :string, :limit => 16, :null => false, :default => "Expanded"
    add_column :emails,   :state, :string, :limit => 16, :null => false, :default => "Expanded"
    execute("UPDATE comments SET state='Expanded'")
    execute("UPDATE emails   SET state='Expanded'")
  end

  def self.down
    remove_column :comments, :state
    remove_column :emails,   :state
  end
end
