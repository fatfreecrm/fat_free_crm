class RemoveContractLengthFromKiosks < ActiveRecord::Migration
  def change
    remove_column :kiosks, :contract_length, :integer
  end
end
