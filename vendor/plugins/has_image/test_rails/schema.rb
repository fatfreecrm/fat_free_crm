ActiveRecord::Schema.define(:version => 1) do

  create_table "pics", :force => true do |t|
    t.string  :has_image_file
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table 'complex_pics', :force => true do |t|
    t.string :filename
    t.integer :width, :height
    t.string :image_size
    t.timestamps
  end

end
