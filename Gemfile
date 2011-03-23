source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Loads the database adapter gem based on config/database.yml (Default: mysql2)
# -----------------------------------------------------------------------------
db_gems = {"mysql2"     => ["mysql2", ">= 0.2.6"],
           "mysql"      => ["mysql"],
           "postgresql" => ["pg",     ">= 0.9.0"],
           "sqlite3"    => ["sqlite3"]}
adapter = if File.exists?(db_config = File.join(File.dirname(__FILE__),"config","database.yml"))
  db = YAML.load_file(db_config)
  # Fetch the first configured adapter from config/database.yml
  (db["production"] || db["development"] || db["test"])["adapter"]
else
  "mysql2"
end
if db_gems[adapter]
  gem *db_gems[adapter]
else
  raise "Sorry, the db adapter in database.yml is unknown. Please add it to 'db_gems' in your Gemfile."
end
# -----------------------------------------------------------------------------

gem 'acts_as_commentable', '>= 3.0.1'
gem 'acts-as-taggable-on', '>= 2.0.6'
gem 'authlogic',           :git => 'git://github.com/crossroads/authlogic.git', :branch => 'rails3'
gem 'haml',                '>= 3.0.24'
gem 'is_paranoid',         :git => 'git://github.com/crossroads/is_paranoid.git', :branch => 'rails3'
gem 'paperclip',           :git => 'git://github.com/crossroads/paperclip.git'
gem 'will_paginate',       '>= 3.0.pre2'

group :development, :test do
  if RUBY_VERSION.to_f >= 1.9
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
  gem 'annotate',           '>= 2.4.0'
  gem 'awesome_print',      '>= 0.3.1'
  gem 'ffaker',             '>= 1.0.0'

  gem "rspec-rails",        '>= 2.4.1'
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

