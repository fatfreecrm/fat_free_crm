class AddRatingAndCategoryToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :rating, :integer, :default => 0, :null => false
    add_column :accounts, :category, :string, :limit => 32
  end

  def self.down
    remove_column :accounts, :category
    remove_column :accounts, :rating
  end
end
