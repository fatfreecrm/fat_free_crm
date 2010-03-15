class AddStateToTimelineObjects < ActiveRecord::Migration
  def self.up
    add_column :comments, :state, :string, :default => "collapsed"
    add_column :emails, :state, :string, :default => "collapsed"
  end

  def self.down
    remove_column :comments, :state
    remove_column :emails, :state
  end
end
