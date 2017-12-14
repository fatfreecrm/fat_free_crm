class AddAccountContactsIndex < ActiveRecord::Migration
  def change
    add_index :account_contacts, %i[account_id contact_id]
  end
end
