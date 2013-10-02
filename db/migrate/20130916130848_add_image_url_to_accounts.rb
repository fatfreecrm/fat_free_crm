class AddImageUrlToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :image_url, :string, :default => nil, :limit => 100
  end

  def self.down
    remove_column :accounts, :image_url
  end
end
