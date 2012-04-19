source :rubygems

# Uncomment the database that you have configured in config/database.yml
# ----------------------------------------------------------------------
# gem 'mysql2', '0.3.10'
# gem 'sqlite3'
gem 'pg', '~> 0.13.2'

# Removes a gem dependency
def remove(name)
  @dependencies.reject! {|d| d.name == name }
end

# Replaces an existing gem dependency (e.g. from gemspec) with an alternate source.
def gem(name, *args)
  remove(name)
  super
end

# Bundler no longer treats runtime dependencies as base dependencies.
# The following code restores this behaviour.
# (See https://github.com/carlhuda/bundler/issues/1041)
spec = Bundler.load_gemspec(Dir["./{,*}.gemspec"].first)
spec.runtime_dependencies.each do |dep|
  gem dep.name, *(dep.requirement.as_list)
end

# Override the following gems with forked repos on GitHub
gem 'ransack',      :git => "https://github.com/fatfreecrm/ransack.git"
gem 'chosen-rails', :git => "https://github.com/fatfreecrm/chosen-rails.git"
gem 'responds_to_parent', :git => "https://github.com/LessonPlanet/responds_to_parent.git"
gem 'email_reply_parser', :git => "https://github.com/ndbroadbent/email_reply_parser.git", :branch => 'ensure_newline_above_underscores'
gem 'premailer', :require => false


# Remove fat_free_crm dependency, to stop it from being auto-required too early.
remove 'fat_free_crm'

group :development, :test do
  gem 'rspec-rails', '~> 2.9.0'
  gem 'steak', :require => false
  gem 'headless'
  unless ENV["CI"]
    gem 'ruby-debug', :platform => :mri_18
    gem 'debugger',   :platform => :mri_19
  end
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'spork'
  gem 'database_cleaner'
  gem 'fuubar'

  if RUBY_VERSION.to_f >= 1.9
    gem 'factory_girl_rails', '~> 3.0.0'
  else
    gem 'factory_girl_rails', '~> 1.7.0'
  end
end

group :heroku do
  gem 'unicorn', :platform => :ruby
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platform => :ruby  # C Ruby (MRI) or Rubinius, but NOT Windows
  gem 'uglifier',     '>= 1.0.3'
end

