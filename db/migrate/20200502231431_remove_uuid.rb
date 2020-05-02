# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030620)

class RemoveUuid < ActiveRecord::Migration[4.2]
  @@uuid_configured = false

  def self.up
    %i[users accounts campaigns leads contacts opportunities tasks].each do |table|
      remove_column "fat_free_crm_#{table}", :uuid
      execute("DROP TRIGGER IF EXISTS fat_free_crm_#{table}_uuid") if uuid_configured?
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover deleted UUIDs"
  end

  def self.uuid_configured?
    return @@uuid_configured if @@uuid_configured

    config = ActiveRecord::Base.connection.instance_variable_get("@config")
    @@uuid_configured = config[:uuid]
  end
end
