class AddAccountContactsIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :account_contacts, %i[account_id contact_id]
  end
end
