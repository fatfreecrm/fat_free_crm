class AddStateToTimelineObjects < ActiveRecord::Migration
  def self.up
    add_column :comments, :state, :string
    add_column :emails, :state, :string
  end

  def self.down
    remove_column :comments, :state
    remove_column :emails, :state
  end
end
