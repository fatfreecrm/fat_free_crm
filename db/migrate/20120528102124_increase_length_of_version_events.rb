# frozen_string_literal: true

class IncreaseLengthOfVersionEvents < ActiveRecord::Migration[4.2]
  def up
    change_column :versions, :event, :string, limit: 512
  end

  def down
    change_column :versions, :event, :string, limit: 255
  end
end
