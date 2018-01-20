# frozen_string_literal: true

class LeadBelongsToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :leads, :account_id, :int

    add_index :leads, :account_id
  end
end
