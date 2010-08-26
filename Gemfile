source 'http://rubygems.org'

gem 'rails', '>= 3.0.0.rc'

gem 'acts_as_commentable'
gem 'acts-as-taggable-on'
gem 'authlogic', '>= 2.1.6'
gem 'gravatar-ultimate', :path => '/home/warp/projects/gravatar/' #:git => 'git://github.com/crossroads/gravatar.git'
gem 'haml'
gem 'mysql'
gem 'paperclip'
gem 'simple_column_search'
gem 'will_paginate', '>= 3.0.pre2'

group :cucumber, :test do
  gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9
  gem 'rspec-rails', '>= 2.0.0.beta.19'
  gem 'faker'
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

group :cucumber, :development, :test do
  if RUBY_VERSION.to_f >= 1.9
    # gem install ruby-debug19 -- --with-ruby-include=/home/user/.rvm/src/ruby-1.9.2-head/
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end
