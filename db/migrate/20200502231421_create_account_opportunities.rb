# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030610)

class CreateAccountOpportunities < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_account_opportunities do |t|
      t.references :account
      t.references :opportunity
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :fat_free_crm_account_opportunities
  end
end
