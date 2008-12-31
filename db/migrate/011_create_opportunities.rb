class CreateOpportunities < ActiveRecord::Migration
  def self.up
    create_table :opportunities, :force => true do |t|
      t.string      :uuid,    :limit => 36
      t.references  :user
      t.references  :account, :null => false
      t.references  :campaign
      t.integer     :assigned_to
      t.string      :name,    :limit => 64, :null => false, :default => ""
      t.string      :source,  :limit => 32
      t.string      :stage,   :limit => 32
      t.integer     :probability
      t.decimal     :amount,           :precision => 12, :scale => 2
      t.date        :closes_on
      t.text        :notes
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :opportunities, [ :user_id, :deleted_at ], :unique => true
    add_index :opportunities, :uuid
    ActiveRecord::Base.connection.execute("CREATE TRIGGER opportunities_uuid BEFORE INSERT ON opportunities FOR EACH ROW SET NEW.uuid = UUID()");
  end

  def self.down
    drop_table :opportunities
  end
end
