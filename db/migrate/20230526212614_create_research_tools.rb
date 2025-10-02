# frozen_string_literal: true

class CreateResearchTools < ActiveRecord::Migration[6.1]
  def change
    create_table :research_tools do |t|
      t.string :name
      t.string :url_template
      t.boolean :enabled, default: false, null: false

      t.timestamps
    end
  end
end
