# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030611)

class CreateContactOpportunities < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_contact_opportunities do |t|
      t.references :contact
      t.references :opportunity
      t.string :role, limit: 32
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :fat_free_crm_contact_opportunities
  end
end
