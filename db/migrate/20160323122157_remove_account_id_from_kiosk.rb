class RemoveAccountIdFromKiosk < ActiveRecord::Migration
  def change
    remove_column :kiosks, :account_id, :integer
  end
end
