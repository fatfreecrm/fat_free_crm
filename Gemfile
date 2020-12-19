# frozen_string_literal: true

source 'https://rubygems.org'

# Uncomment the database that you have configured in config/database.yml
# ----------------------------------------------------------------------

case ENV['CI'] && ENV['DB']
when 'sqlite'
  gem 'sqlite3', '~> 1.3.13'
when 'mysql'
  gem 'mysql2'
when 'postgres'
  gem 'pg'
else
  gem 'pg'
end

# Removes a gem dependency
def remove(name)
  @dependencies.reject! { |d| d.name == name }
end

# Replaces an existing gem dependency (e.g. from gemspec) with an alternate source.
def gem(name, *args)
  remove(name)
  super
end

# Bundler no longer treats runtime dependencies as base dependencies.
# The following code restores this behaviour.
# (See https://github.com/carlhuda/bundler/issues/1041)
spec = Bundler.load_gemspec(File.expand_path('fat_free_crm.gemspec', __dir__))
spec.runtime_dependencies.each do |dep|
  gem dep.name, *dep.requirement.as_list
end

# Remove premailer auto-require
gem 'premailer', require: false

# Remove fat_free_crm dependency, to stop it from being auto-required too early.
remove 'fat_free_crm'

group :development do
  # don't load these gems in travis
  unless ENV["CI"]
    gem 'capistrano'
    gem 'capistrano-bundler'
    gem 'capistrano-rails'
    gem 'capistrano-rvm'
    gem 'guard'
    gem 'guard-rspec'
    gem 'guard-rails'
    gem 'rb-inotify', require: false
    gem 'rb-fsevent', require: false
    gem 'rb-fchange', require: false
    gem 'brakeman', require: false
  end
end

group :development, :test do
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'headless'
  gem 'byebug'
  gem 'pry-rails' unless ENV["CI"]
  gem 'factory_bot_rails', '~> 5.0' # Was Pinned due to minor failing view tests to 4.0
  gem 'rubocop', '~> 0.76.0' # Pinned because upgrades require regenerating rubocop_todo.yml
  gem 'rainbow'
  gem 'puma' # used by capybara 3
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'database_cleaner'
  gem 'zeus', platform: :ruby unless ENV["CI"]
  gem 'timecop'
  gem 'sqlite3', '~> 1.3.13'
end

group :heroku do
  gem 'rails_12factor'
  gem 'puma'
end

gem 'sass-rails', '~> 5.0.3' # sass-rails 6 requires GCC 4.5+
gem 'coffee-rails'
gem 'uglifier'
gem 'execjs'
gem 'therubyracer', platform: :ruby unless ENV["CI"]
gem 'nokogiri', '>= 1.8.1'
gem 'activemodel-serializers-xml'
gem 'bootsnap', require: false
gem 'devise', '~>4.6'
gem 'devise-i18n'
gem "devise-encryptable"
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'activejob', '~> 5.2.0'
gem 'ransack_ui', path: 'vendor/gems/ransack_ui-1.3.4' # Vendored until our fix is merged and released
gem 'spreadsheet'

gem "roo", "~> 2.8"

gem "roo-xls", "~> 1.2"
