source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Uncomment the database that you have configured in config/database.yml
# ----------------------------------------------------------------------
# gem "mysql2", "0.3.10"
# gem "sqlite3"
gem "pg", ">= 0.9.0"

gem 'authlogic',           '~> 3.1.0'
gem 'acts_as_commentable', '>= 3.0.1'
gem 'acts-as-taggable-on', '>= 2.0.6'
gem 'haml',                '>= 3.1.1'
gem 'paperclip',           '~> 2.4.5'
gem 'will_paginate',       '>= 3.0.pre2'
gem 'acts_as_list',        '~> 0.1.4'
gem 'simple_form',         '~> 1.5.2'
gem 'prototype-rails',     '>= 3.1.0'
gem 'ffaker',              '>= 1.5.0' # For demo data
gem 'uglifier'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.1.1'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'therubyracer'
end

group :development, :test do
  gem 'ruby-debug',   :platform => :mri_18
  gem 'ruby-debug19', :platform => :mri_19, :require => 'ruby-debug'
  gem 'annotate',           '~> 2.4.1.beta', :require => false
  gem 'awesome_print',      '>= 0.3.1'

  gem 'test-unit',          '2.4.2',  :platform => :mri_19
  gem 'rspec-rails',        '>= 2.5.0'
  gem 'ffaker',             '>= 1.5.0'
  gem 'factory_girl',       '>= 1.3.3'
end

group :test do
  gem 'factory_girl_rails', '~> 1.4.0'
  gem 'simplecov', :platform => :mri_19
  gem 'fuubar'
end

group :heroku do
  gem 'unicorn'
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
