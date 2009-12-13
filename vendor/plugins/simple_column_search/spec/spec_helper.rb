require 'spec'
require 'fileutils'


$: << File.join(File.dirname(__FILE__), '..', 'lib')

require File.join(File.dirname(__FILE__), '..', 'init')

TEST_DATABASE_FILE = File.join(File.dirname(__FILE__), 'test.sqlite3')

Spec::Runner.configure do |config|
  
end

def setup_database
  File.unlink(TEST_DATABASE_FILE) if File.exist?(TEST_DATABASE_FILE)
  ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3", "timeout" => 5000, "database" => TEST_DATABASE_FILE
  )
  create_tables
end

def create_tables
  c = ActiveRecord::Base.connection
  
  c.create_table :people, :force => true do |t|
    t.string :first_name
    t.string :last_name
    t.string :alias
    t.timestamps
  end
end

setup_database

require File.join(File.dirname(__FILE__), 'models')
