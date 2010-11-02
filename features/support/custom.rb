require "factory_girl"
require "#{::Rails.root}/spec/factories"

if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'

    # Restart identity fix for postgresql
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)} RESTART IDENTITY #{cascade};")
      end
    end
    DatabaseCleaner.app_root = ::Rails.root
    DatabaseCleaner.strategy = :truncation, {:except => ['settings']}

    # Make sure the database is clean and shiny before we start testing
    DatabaseCleaner.clean
  rescue LoadError => ignore_if_database_cleaner_not_present
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
