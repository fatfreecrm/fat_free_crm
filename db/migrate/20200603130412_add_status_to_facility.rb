class AddStatusToFacility < ActiveRecord::Migration[6.0]
  def change
    add_column    :fat_free_crm_facilities, :status, :string
  end
end