# frozen_string_literal: true

class AddIndexesToModelAssociations < ActiveRecord::Migration[4.2]
  def change
    add_index :contact_opportunities, %i[contact_id opportunity_id]
    add_index :account_opportunities, %i[account_id opportunity_id]
  end
end
