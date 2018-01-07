# frozen_string_literal: true

class RemoveUuid < ActiveRecord::Migration[4.2]
  @@uuid_configured = false

  def self.up
    %i[users accounts campaigns leads contacts opportunities tasks].each do |table|
      remove_column table, :uuid
      execute("DROP TRIGGER IF EXISTS #{table}_uuid") if uuid_configured?
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
