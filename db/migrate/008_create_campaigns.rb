class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns, :force => true do |t|
      t.string      :uuid,   :limit => 36
      t.references  :user
      t.string      :name,   :limit => 64, :null => false, :default => ""
      t.string      :status, :limit => 64
      t.decimal     :budget, :precision => 12, :scale => 2
      t.integer     :target_leads
      t.float       :target_conversion
      t.decimal     :target_revenue, :precision => 12, :scale => 2
      t.integer     :actual_leads
      t.float       :actual_conversion
      t.decimal     :actual_revenue, :precision => 12, :scale => 2
      t.date        :starts_on
      t.date        :ends_on
      t.text        :objectives
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
