class AddMandrillToUser < ActiveRecord::Migration
  def up
    add_column :users, :mandrill, :boolean
  end
  
  def down
    remove_column :users, :mandrill
  end
  
end
