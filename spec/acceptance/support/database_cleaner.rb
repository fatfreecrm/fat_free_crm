#
# Clean database when transactions are turned off.
# See http://github.com/bmabey/database_cleaner for more info.
#
if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation, {:except => ['settings']}
    RSpec.configuration.use_transactional_fixtures = false
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

RSpec.configuration.before(:each, :type => :acceptance) do
  DatabaseCleaner.clean
end
