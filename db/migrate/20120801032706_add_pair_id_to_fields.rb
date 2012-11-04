class AddPairIdToFields < ActiveRecord::Migration
  def change
    add_column :fields, :pair_id, :integer
  end
end
