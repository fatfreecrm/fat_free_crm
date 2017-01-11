class RemoveDefaultValueAndClearSettings < ActiveRecord::Migration
  def up
    remove_column :settings, :default_value

    # Truncate settings table
    if connection.adapter_name.casecmp("sqlite").zero?
      execute("DELETE FROM settings")
    else # mysql and postgres
      execute("TRUNCATE settings")
    end
  end

  def down
    add_column :settings, :default_value, :text
  end
end
