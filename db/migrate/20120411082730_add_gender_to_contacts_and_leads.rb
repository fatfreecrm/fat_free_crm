class AddGenderToContactsAndLeads < ActiveRecord::Migration
  def change
    with_options :limit => 1, :default => 'm' do |o|
      o.add_column :contacts, :gender, :string
      o.add_column :leads,    :gender, :string
    end
  end
end
