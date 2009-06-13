$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rubygems'
if ENV['RAILS'].nil?
  require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
else
  # specific rails version targeted
  # load activerecord and plugin manually
  gem 'activerecord', "=#{ENV['RAILS']}"
  require 'active_record'
  $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
  Dir["#{$LOAD_PATH.last}/**/*.rb"].each do |path| 
    require path[$LOAD_PATH.last.size + 1..-1]
  end
  require File.join(File.dirname(__FILE__), '..', 'init.rb')
end
require 'active_record/fixtures'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
# do this so fixtures will load
ActiveRecord::Base.configurations.update config 
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + "/schema.rb")

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
end
