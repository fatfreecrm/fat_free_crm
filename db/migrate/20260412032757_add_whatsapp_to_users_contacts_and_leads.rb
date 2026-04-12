# frozen_string_literal: true

class AddWhatsappToUsersContactsAndLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :whatsapp, :string, limit: 128
    add_column :contacts, :whatsapp, :string, limit: 128
    add_column :leads, :whatsapp, :string, limit: 128
  end
end
