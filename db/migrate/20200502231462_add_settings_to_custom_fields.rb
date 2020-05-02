# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20121003063155)

class AddSettingsToCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fat_free_crm_fields, :settings, :text, default: nil
  end
end
