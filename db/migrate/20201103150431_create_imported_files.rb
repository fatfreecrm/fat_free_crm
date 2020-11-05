# frozen_string_literal: true

class CreateImportedFiles < ActiveRecord::Migration[4.2]
  def self.up
    create_table :imported_files, force: true do |t|
      t.string :filename,  limit: 64, null: false, default: ""
      t.string :md5sum,    limit: 32, null: false, default: ""

      t.timestamps
    end
  end

  def self.down
    drop_table :imported_files
  end
end
