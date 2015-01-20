class AddSettingsToCustomFields < ActiveRecord::Migration
  def change
    add_column :fields, :settings, :text, default: nil
  end
end
