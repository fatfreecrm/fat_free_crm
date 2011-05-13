class AddLastUpdatedByFieldToOpportunities < ActiveRecord::Migration
  def self.up
    add_column :opportunities, :last_updated_by, :integer
  end

  def self.down
    remove_column :opportunities, :last_updated_by
  end
end
