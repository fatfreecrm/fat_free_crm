class AddPairIdToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :pair_id, :integer
  end
end
