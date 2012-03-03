source 'http://rubygems.org'

gem 'rails', '3.1.3'
gem 'prototype-rails'

# Uncomment the database that you have configured in config/database.yml
# ----------------------------------------------------------------------
# gem "mysql2", "0.3.10"
gem "sqlite3"
gem "pg", "~> 0.12.2"

gem 'authlogic',           '~> 3.1.0'
gem 'acts_as_commentable', '~> 3.0.1'
gem 'acts-as-taggable-on', '~> 2.2.1'
gem 'haml',                '~> 3.1.3'
gem 'paperclip',           '~> 2.5.2'
gem 'will_paginate',       '~> 3.0.2'
gem 'acts_as_list',        '~> 0.1.4'
gem 'simple_form',         '~> 1.5.2'
gem 'ffaker',              '>= 1.12.0' # For loading demo data
gem 'uglifier'
gem 'ajax-chosen-rails',   '>= 0.1.5'
gem 'chosen-rails'#,        :git => "git://github.com/fatfreecrm/chosen-rails.git"
gem 'ransack'#,             :git => "git://github.com/ndbroadbent/ransack.git"
gem 'jquery-rails'

# Bushido dependencies
gem 'bushido'
gem 'tane', :group => :development
gem 'authlogic_bushido', '~> 0.9'

group :heroku do
  gem 'unicorn', :platform => :ruby
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 3.1.1'
  gem 'coffee-rails', '>= 3.1.1'
  gem 'execjs'
end

group :development, :test do
  unless ENV["CI"] || ENV["HOSTING_PLATFORM"] == "bushido"
    # gem 'ruby-debug',   :platform => :mri_18
    # gem 'ruby-debug19', :platform => :mri_19, :require => 'ruby-debug' if RUBY_VERSION == "1.9.2"
    gem 'awesome_print'
  end

  gem 'test-unit',          '~> 2.4.3',  :platform => :mri_19, :require => false
  gem 'rspec-rails',        '~> 2.8.0'
  gem 'factory_girl'
  gem 'steak',              '~> 2.0.0'
  gem 'headless',           '~> 0.2.2'
end

group :development do
  platforms :ruby do
    # These gems give you an awesome development environment.
    gem 'thin'
    gem 'guard'             # https://github.com/guard/guard
    gem 'guard-rails'       # https://github.com/guard/guard-rails
    gem 'guard-sass'        # https://github.com/guard/guard-sass
    gem 'guard-spork'       # https://github.com/guard/guard-spork
    gem 'guard-rspec'       # https://github.com/guard/guard-rspec
    gem 'guard-livereload'  # https://github.com/guard/guard-livereload
    gem 'ruby_gntp'
    gem 'yajl-ruby'
  end
  # For annotating models with Schema information
  gem 'annotate', '~> 2.4.1.beta', :require => false, :group => :development
end

group :test do
  gem 'spork'
  gem 'factory_girl_rails', '~> 1.6.0'
  gem 'simplecov', :platform => :mri_19 unless ENV["CI"]  # Until Travis supports build artifacts
  gem 'fuubar'
  gem 'database_cleaner'
end


# Rails3 plugins that we use and their source repositories:
#---------------------------------------------------------------------
# gravatar_image_tag,      git://github.com/mdeering/gravatar_image_tag.git
# calendar_date_select,    git://github.com/timcharper/calendar_date_select.git
# country_select,          git://github.com/rails/country_select.git
# dynamic_form,            git://github.com/rails/dynamic_form.git
# is_paranoid,             git://github.com/theshortcut/is_paranoid.git
# prototype_legacy_helper, git://github.com/rails/prototype_legacy_helper.git
# responds_to_parent,      git://github.com/markcatley/responds_to_parent.git
