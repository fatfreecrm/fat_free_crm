class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns, :force => true do |t|
      t.string      :uuid,   :limit => 36
      t.references  :user
      t.string      :name,   :limit => 64, :null => false, :default => ""
      t.string      :type,   :limit => 64
      t.string      :stage,  :limit => 64
      t.decimal     :budget,           :precision => 12, :scale => 2
      t.decimal     :actual_cost,      :precision => 12, :scale => 2
      t.decimal     :expected_revenue, :precision => 12, :scale => 2
      t.integer     :expected_leads
      t.date        :starts_on
      t.date        :ends_on
      t.text        :objective
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :campaigns, [ :user_id, :name, :deleted_at ], :unique => true
    add_index :campaigns, :uuid
    ActiveRecord::Base.connection.execute("CREATE TRIGGER campaigns_uuid BEFORE INSERT ON campaigns FOR EACH ROW SET NEW.uuid = UUID()");
  end

  def self.down
    drop_table :campaigns
  end
end
