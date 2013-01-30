class AddSaasuUidToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :saasu_uid, :integer
  end
  
  def down
    remove_column :contacts, :saasu_uid
  end
end
