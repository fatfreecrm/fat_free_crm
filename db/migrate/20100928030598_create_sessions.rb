# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[4.2]
  def self.up
    # Set the following global variable to show that we are migrating
    # from a brand new database. Future migrations can detect this, and
    # avoid running unnecessary code.
    $FFCRM_NEW_DATABASE = true

    create_table :sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end

  def self.down
    drop_table :sessions
  end
end
