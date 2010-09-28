class CreateAccountOpportunities < ActiveRecord::Migration
  def self.up
    create_table :account_opportunities, :force => true do |t|
      t.references :account
      t.references :opportunity
      t.datetime   :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :account_opportunities
  end
end
