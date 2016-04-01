class AddContractsRefToKiosks < ActiveRecord::Migration
  def change
    add_reference :kiosks, :contract, index: true, foreign_key: true
  end
end
