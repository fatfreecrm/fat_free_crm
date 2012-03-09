class AddVersionsRelated < ActiveRecord::Migration
  def change
    add_column :versions, :related_id, :integer
    add_column :versions, :related_type, :string
  end
end
