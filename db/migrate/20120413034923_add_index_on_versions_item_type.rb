# frozen_string_literal: true

class AddIndexOnVersionsItemType < ActiveRecord::Migration[4.2]
  def change
    add_index :versions, :whodunnit
  end
end
