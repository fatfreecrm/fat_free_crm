# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

old_stdout = $stdout
$stdout = StringIO.new

begin
  ActiveRecord::Schema.define do
    create_table :androids do |t|
      t.string   :name
      t.integer  :owner_id
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :people do |t|
      t.string   :name
      t.timestamps
    end
  end
ensure
  $stdout = old_stdout
end

