class AddAccountContactsIndex < ActiveRecord::Migration
  def change
    add_index :account_contacts, [:account_id, :contact_id]
  end
end
