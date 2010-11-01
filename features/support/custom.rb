require "factory_girl"
require "#{::Rails.root}/spec/factories"

# Restart identity fix for postgresql
require 'database_cleaner'
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  def truncate_table(table_name)
    execute("TRUNCATE TABLE #{quote_table_name(table_name)} #{cascade} RESTART IDENTITY;")
  end
end

# Require plugin.rb support files from each plugin.
Dir.glob("#{Rails.root}/vendor/plugins/**/support/plugin.rb").each {|f| require f }

# Default timeout should be longer since this is an AJAX based application.
Capybara.default_wait_time = 7

# Cancel any activity logging for Comment model (breaks cucumber tests)
Comment.class_eval do
  def log_activity; end
end

# Make sure the database is clean and shiny before we start testing
# DatabaseCleaner.clean

