class CreateIndexRelatedType < ActiveRecord::Migration
  def up
    add_index :versions, %i[related_id related_type]
  end

  def down
    remove_index :versions, %i[related_id related_type]
  end
end
