class AddNameToFacility < ActiveRecord::Migration[6.0]
  def change
    add_column  :fat_free_crm_facilities, :name, :string
  end
end