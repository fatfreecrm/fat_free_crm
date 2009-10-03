class RemoveUuid < ActiveRecord::Migration
  @@uuid_configured = false

  def self.up
    [ :users, :accounts, :campaigns, :leads, :contacts, :opportunities, :tasks ].each do |table|
      remove_column table, :uuid
      if self.uuid_configured?
        execute("DROP TRIGGER IF EXISTS #{table}_uuid")
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover deleted UUIDs"
  end

  private
  def self.uuid_configured?
    return @@uuid_configured if @@uuid_configured
    config = ActiveRecord::Base.connection.instance_variable_get("@config")
    @@uuid_configured = config[:uuid]
  end
end
