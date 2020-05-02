# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030622)

class AddBackgroundInfoToModels < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_accounts, :background_info, :string
    add_column :fat_free_crm_campaigns, :background_info, :string
    add_column :fat_free_crm_contacts, :background_info, :string
    add_column :fat_free_crm_leads, :background_info, :string
    add_column :fat_free_crm_opportunities, :background_info, :string
    add_column :fat_free_crm_tasks, :background_info, :string
  end

  def self.down
    remove_column :fat_free_crm_accounts, :background_info
    remove_column :fat_free_crm_campaigns, :background_info
    remove_column :fat_free_crm_contacts, :background_info
    remove_column :fat_free_crm_leads, :background_info
    remove_column :fat_free_crm_opportunities, :background_info
    remove_column :fat_free_crm_tasks, :background_info
  end
end
