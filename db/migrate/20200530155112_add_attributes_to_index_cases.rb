class AddAttributesToIndexCases < ActiveRecord::Migration[6.0]
  def change
    add_column    :fat_free_crm_index_cases, :category, :string
    add_reference :fat_free_crm_index_cases, :opportunity, index: true
    
  end
end