class AddUploadedByIdColumnToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :uploaded_by_id, :string
  end
end
