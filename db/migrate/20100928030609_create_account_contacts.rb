# frozen_string_literal: true

class CreateAccountContacts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :account_contacts do |t|
      t.references :account
      t.references :contact
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :account_contacts
  end
end
