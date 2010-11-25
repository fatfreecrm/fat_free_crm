class CreateContactOpportunities < ActiveRecord::Migration
  def self.up
    create_table :contact_opportunities, :force => true do |t|
      t.references :contact
      t.references :opportunity
      t.string     :role, :limit => 32
      t.datetime   :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_opportunities
  end
end
