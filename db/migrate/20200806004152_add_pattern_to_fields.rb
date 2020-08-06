class AddPatternToFields < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :pattern, :string
  end
end
