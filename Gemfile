source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Uncomment the database adapter you would like to use.
# -----------------------------------------------------
# gem 'pg', '>= 0.9.0'
gem 'mysql2',              '>= 0.2.6'
# -----------------------------------------------------

gem 'acts_as_commentable', '>= 3.0.1'
gem 'acts-as-taggable-on', '>= 2.0.6'
gem 'authlogic',           :git => 'git://github.com/crossroads/authlogic.git', :branch => 'rails3'
gem 'haml',                '>= 3.0.24'
gem 'is_paranoid',         :git => 'git://github.com/crossroads/is_paranoid.git', :branch => 'rails3'
gem 'paperclip',           :git => 'git://github.com/crossroads/paperclip.git'
gem 'will_paginate',       '>= 3.0.pre2'
gem 'meta_search',         '>= 0.9.9.1'

group :development do
  gem 'annotate',           '>= 2.4.0'
end

group :development, :test do
  if RUBY_VERSION.to_f >= 1.9
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
  gem 'awesome_print',      '>= 0.3.1'
  gem 'ffaker',             '>= 1.0.0'
end

group :test do
  gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9
  gem "rspec-rails",        '>= 2.4.1'
  gem "rspec",              '>= 2.4.0'
  gem "rspec-core",         '>= 2.4.0'
  gem "rspec-expectations", '>= 2.4.0'
  gem "rspec-mocks",        '>= 2.4.0'
  gem 'factory_girl',       '>= 1.3.2'
end


# Gem watch list:
#---------------------------------------------------------------------
# gem 'authlogic',         :git => 'git://github.com/crossroads/authlogic.git', :branch => 'rails3'
# gem 'gravatar-ultimate', :git => 'git://github.com/crossroads/gravatar.git'
# gem 'paperclip',         :git => 'http://github.com/thoughtbot/paperclip.git'

# Rails3 plugins that we use and their source repositories:
#---------------------------------------------------------------------
# gravatar_image_tag,      git://github.com/mdeering/gravatar_image_tag.git
# calendar_date_select,    git://github.com/timcharper/calendar_date_select.git
# country_select,          git://github.com/rails/country_select.git
# dynamic_form,            git://github.com/rails/dynamic_form.git
# is_paranoid,             git://github.com/theshortcut/is_paranoid.git
# prototype_legacy_helper, git://github.com/rails/prototype_legacy_helper.git
# responds_to_parent,      git://github.com/markcatley/responds_to_parent.git

