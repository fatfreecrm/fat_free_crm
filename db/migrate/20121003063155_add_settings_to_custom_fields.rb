class AddSettingsToCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :settings, :text, default: nil
  end
end
