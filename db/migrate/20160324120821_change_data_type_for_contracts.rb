class ChangeDataTypeForContracts < ActiveRecord::Migration
  def change
    remove_column :kiosks, :contract_type
  end
end
