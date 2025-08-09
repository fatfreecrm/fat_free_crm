# frozen_string_literal: true

class AddAccountCounterCaches < ActiveRecord::Migration[5.1]
  def change
    change_table :accounts do |t|
      t.integer :contacts_count, default: 0
      t.integer :opportunities_count, default: 0
    end

    reversible do |dir|
      dir.up { data }
    end
  end

  def data
    Account.all.each do |account|
      Account.update_counters(
        account.id,
        contacts_count: account.contacts.count,
        opportunities_count: account.opportunities.count
      )
    end
  end
end
