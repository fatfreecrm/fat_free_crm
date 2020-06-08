class AddAttributesToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_accounts, :division_name, :string
  end
end