# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030598)

class CreateSessions < ActiveRecord::Migration[4.2]
  def self.up
    # Set the following global variable to show that we are migrating
    # from a brand new database. Future migrations can detect this, and
    # avoid running unnecessary code.
    $FFCRM_NEW_DATABASE = true

    create_table :fat_free_crm_sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.timestamps
    end

    add_index :fat_free_crm_sessions, :session_id
    add_index :fat_free_crm_sessions, :updated_at
  end

  def self.down
    drop_table :fat_free_crm_sessions
  end
end
