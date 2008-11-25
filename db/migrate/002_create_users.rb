class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :username,      :string, :limit => 32, :null => false
      t.column :email,         :string, :limit => 64, :null => false
      t.column :password,      :string, :limit => 32, :null => false
      t.column :first_name,    :string, :limit => 32
      t.column :last_name,     :string, :limit => 32
      t.column :last_login_at, :datetime
      t.timestamps
    end     

    add_index :users, :username, :unique => true
    add_index :users, :email
    User.create(:username => "system", :password => "manager", :email => "mike@dvorkin.net")
  end

  def self.down
    drop_table :users
  end
end
