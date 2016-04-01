class AddAccountIdToKiosks < ActiveRecord::Migration
  def change
    add_column :kiosks, :account_id, :integer
  end
end
