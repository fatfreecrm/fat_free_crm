source :rubygems

gem 'bundler', '>= 0.9.26'
gem 'rake'
gem 'activerecord', '>= 3.0.0.beta4'

if RUBY_VERSION.to_f >= 1.9
  # -- --with-ruby-include=$HOME/.rvm/src/ruby-1.9.2p0/
  gem 'ruby-debug19'
else
  gem 'ruby-debug'
end

group :test do
  gem 'rspec', '>= 2.0.0'
  gem 'sqlite3-ruby', :require => 'sqlite3'
end
