# frozen_string_literal: true

class AddImageUrlToModels < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :image_url, :string
    add_column :leads, :image_url, :string
    add_column :contacts, :image_url, :string
  end
end
