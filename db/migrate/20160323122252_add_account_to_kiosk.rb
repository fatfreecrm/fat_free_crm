class AddAccountToKiosk < ActiveRecord::Migration
  def change
    add_reference :kiosks, :account, index: true, foreign_key: true
  end
end
