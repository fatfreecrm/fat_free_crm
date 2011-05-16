class RemoveLastUpdatedByFromOpportunities < ActiveRecord::Migration
  def self.up
    remove_column :opportunities, :last_updated_by 
  end

  def self.down
    add_column :opportunities, :last_updated_by, :integer
  end
end
