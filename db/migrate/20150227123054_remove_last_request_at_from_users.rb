class RemoveLastRequestAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_request_at
  end
end
