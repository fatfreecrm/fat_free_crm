# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20140916012922)

class AddIndexesToModelAssociations < ActiveRecord::Migration[4.2]
  def change
    add_index :fat_free_crm_contact_opportunities, %i[contact_id opportunity_id], name: 'contact_opportunities_index'
    add_index :fat_free_crm_account_opportunities, %i[account_id opportunity_id], name: 'account_opportunities_index'
  end
end
