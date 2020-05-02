# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20180102075234)

class AddAccountCounterCaches < ActiveRecord::Migration[5.1]
  def change
    change_table :fat_free_crm_accounts do |t|
      t.integer :contacts_count, default: 0
      t.integer :opportunities_count, default: 0
    end

    reversible do |dir|
      dir.up { data }
    end
  end

  def data
    FatFreeCrm::Account.all.each do |account|
      FatFreeCrm::Account.update_counters(
        account.id,
        contacts_count: account.contacts.count,
        opportunities_count: account.opportunities.count
      )
    end
  end
end
