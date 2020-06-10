class AddCaseNumberToIndexCases < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_index_cases, :case_number, :string
  end
end