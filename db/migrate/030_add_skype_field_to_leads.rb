class AddSkypeFieldToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :skype, :string, :limit => 64
  end

  def self.down
    remove_column :leads, :skype
  end
end
