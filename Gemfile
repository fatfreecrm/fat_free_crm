source 'http://rubygems.org'

gem 'rails', '>= 3.0.0.rc2'

gem 'acts_as_commentable', '>= 3.0.0'
gem 'acts-as-taggable-on', '>= 2.0.6'
gem 'authlogic', '>= 2.1.6'
gem 'gravatar-ultimate', :path => '/home/warp/projects/gravatar/' #:git => 'git://github.com/crossroads/gravatar.git'
gem 'haml', '>= 3.0.17'
gem 'mysql', '>= 2.8.1'
gem 'paperclip', '>= 2.3.3'
gem 'simple_column_search', '>= 1.0.1'
gem 'will_paginate', '>= 3.0.pre2'

group :cucumber, :development, :test do
  gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9
  gem 'rspec-rails', '>= 2.0.0.beta.20'

  if RUBY_VERSION.to_f >= 1.9
    # gem install ruby-debug19 -- --with-ruby-include=/home/user/.rvm/src/ruby-1.9.2-head/
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end

group :cucumber, :test do
  gem 'ffaker'
  gem 'factory_girl'
end

group :cucumber do
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'spork'
end

group :test do
  gem 'shoulda'
  gem 'autotest-rails'
end
