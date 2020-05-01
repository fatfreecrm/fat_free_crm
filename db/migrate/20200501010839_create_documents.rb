class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :creator
      t.string :subject
      t.string :description
      t.string :publisher
      t.string :contributor
      t.date :date
      t.string :type
      t.string :format
      t.string :identifier
      t.string :source
      t.string :language
      t.string :relation
      t.string :coverage
      t.string :rights
      t.string :size
      t.text :tags

      t.timestamps
    end
  end
end
