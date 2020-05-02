# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030606)

class CreateLeads < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_leads do |t|
      t.string :uuid, limit: 36
      t.references :user
      t.references :campaign
      t.integer :assigned_to
      t.string :first_name,  limit: 64, null: false, default: ""
      t.string :last_name,   limit: 64, null: false, default: ""
      t.string :access,      limit: 8, default: "Public"
      t.string :title,       limit: 64
      t.string :company,     limit: 64
      t.string :source,      limit: 32
      t.string :status,      limit: 32
      t.string :referred_by, limit: 64
      t.string :email,       limit: 64
      t.string :alt_email,   limit: 64
      t.string :phone,       limit: 32
      t.string :mobile,      limit: 32
      t.string :blog,        limit: 128
      t.string :linkedin,    limit: 128
      t.string :facebook,    limit: 128
      t.string :twitter,     limit: 128
      t.string :address
      t.integer :rating,      null: false, default: 0
      t.boolean :do_not_call, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :fat_free_crm_leads, %i[user_id last_name deleted_at], unique: true, name: 'ffcrm_big_index'
    add_index :fat_free_crm_leads, :assigned_to
  end

  def self.down
    drop_table :fat_free_crm_leads
  end
end
