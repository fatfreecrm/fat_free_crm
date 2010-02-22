class AddBackgroundInfoToModels < ActiveRecord::Migration
  def self.up
    add_column :accounts, :background_info, :string
    add_column :campaigns, :background_info, :string
    add_column :contacts, :background_info, :string
    add_column :leads, :background_info, :string
    add_column :opportunities, :background_info, :string
    add_column :tasks, :background_info, :string
  end

  def self.down
    remove_column :accounts, :background_info
    remove_column :campaigns, :background_info
    remove_column :contacts, :background_info
    remove_column :leads, :background_info
    remove_column :opportunities, :background_info
    remove_column :tasks, :background_info
  end
end
