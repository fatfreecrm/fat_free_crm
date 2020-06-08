class CreateAccountsFacilitiesJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_accounts_facilities, id: false do |t|
      t.references :account
      t.references :facility
    end
  end
end