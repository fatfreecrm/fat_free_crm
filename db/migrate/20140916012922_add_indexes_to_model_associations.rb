class AddIndexesToModelAssociations < ActiveRecord::Migration
  def change
    add_index :contact_opportunities, [:contact_id, :opportunity_id]
    add_index :account_opportunities, [:account_id, :opportunity_id]
  end
end
