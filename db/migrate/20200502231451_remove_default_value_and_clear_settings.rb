# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120224073107)

class RemoveDefaultValueAndClearSettings < ActiveRecord::Migration[4.2]
  def up
    remove_column :fat_free_crm_settings, :default_value

    # Truncate settings table
    if connection.adapter_name.casecmp("sqlite").zero?
      execute("DELETE FROM fat_free_crm_settings")
    else # mysql and postgres
      execute("TRUNCATE fat_free_crm_settings")
    end
  end

  def down
    add_column :fat_free_crm_settings, :default_value, :text
  end
end
