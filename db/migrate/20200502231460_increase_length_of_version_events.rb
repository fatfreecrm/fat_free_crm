# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120528102124)

class IncreaseLengthOfVersionEvents < ActiveRecord::Migration[4.2]
  def up
    change_column :fat_free_crm_versions, :event, :string, limit: 512
  end

  def down
    change_column :fat_free_crm_versions, :event, :string, limit: 255
  end
end
