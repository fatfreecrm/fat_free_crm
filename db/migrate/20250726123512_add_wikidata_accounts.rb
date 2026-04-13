# frozen_string_literal: true

class AddWikidataAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :wikidata_id, :string, null: true
  end
end
