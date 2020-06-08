class AddAttributesToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column    :fat_free_crm_addresses, :county, :string
    add_column    :fat_free_crm_addresses, :state_code, :integer
    add_column    :fat_free_crm_addresses, :county_code, :integer

    
  end
end