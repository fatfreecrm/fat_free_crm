class AddUploadedByIdColumnToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_documents, :uploaded_by_id, :string
  end
end
