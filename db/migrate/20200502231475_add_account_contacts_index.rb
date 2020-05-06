# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20160511053730)

class AddAccountContactsIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :fat_free_crm_account_contacts, %i[account_id contact_id], name: 'account_contacts_index'
  end
end
