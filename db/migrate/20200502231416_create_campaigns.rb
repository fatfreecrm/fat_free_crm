# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030605)

class CreateCampaigns < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_campaigns do |t|
      t.string :uuid, limit: 36
      t.references :user
      t.integer :assigned_to
      t.string :name,   limit: 64, null: false, default: ""
      t.string :access, limit: 8, default: "Public" # %w(Private Public Shared)
      t.string :status, limit: 64
      t.decimal :budget, precision: 12, scale: 2
      # Target metrics.
      t.integer :target_leads
      t.float :target_conversion # leads-to-opportunities conversion ratio (%)
      t.decimal :target_revenue, precision: 12, scale: 2
      # Actual metrics.
      t.integer :leads_count
      t.integer :opportunities_count
      t.decimal :revenue, precision: 12, scale: 2
      # Dates.
      t.date :starts_on
      t.date :ends_on
      t.text :objectives
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :fat_free_crm_campaigns, %i[user_id name deleted_at], unique: true
    add_index :fat_free_crm_campaigns, :assigned_to
  end

  def self.down
    drop_table :fat_free_crm_campaigns
  end
end
