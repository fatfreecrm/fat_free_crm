# frozen_string_literal: true

source 'https://rubygems.org'

# Uncomment the database that you have configured in config/database.yml
# ----------------------------------------------------------------------

case ENV['CI'] && ENV['DB']
when 'sqlite'
  gem 'sqlite3', '~> 1.6.8'
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
  gem 'factory_bot_rails', '~> 6.0'
  gem 'rubocop'
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
  gem 'sqlite3', '~> 1.6.8'
  gem 'webrick'
end

group :heroku do
  gem 'rails_12factor'
  gem 'puma'
end

gem 'responds_to_parent', git: 'https://github.com/RedPatchTechnologies/responds_to_parent.git', branch: 'master' # Temporarily pointed at git until https://github.com/zendesk/responds_to_parent/pull/7 is released
gem 'acts_as_commentable', git: 'https://github.com/fatfreecrm/acts_as_commentable.git', branch: 'main' # Our fork
gem 'sassc-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'execjs'
# gem 'therubyracer', platform: :ruby unless ENV["CI"]
gem 'mini_racer'
gem 'nokogiri', '>= 1.8.1'
gem 'activemodel-serializers-xml'
gem 'bootsnap', require: false
gem 'devise', '~>4.6'
gem 'devise-i18n'
gem "devise-encryptable"
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'activejob'
gem 'ransack_ui'
gem 'bootstrap', '~>5.0.0'
gem 'mini_magick'
gem 'image_processing', '~> 1.2'
gem 'jquery-ui-rails', git: 'https://github.com/jquery-ui-rails/jquery-ui-rails.git', tag: 'v7.0.0' # See https://github.com/jquery-ui-rails/jquery-ui-rails/issues/146
