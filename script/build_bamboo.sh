# Make a directory for webcam videos
mkdir -p ./log/punishments
touch ./log/punishments/missile_log.avi

# Project variables
# -----------------------------------------------------
ruby_version=1.9.2
bundler_version=1.0.0

ruby_packages="ruby ruby-devel gcc rubygems"
cucumber_packages="libxml2 libxml2-devel libxslt libxslt-devel xorg-x11-server-Xvfb firefox ImageMagick"
required_packages="$ruby_packages $cucumber_packages"

crm_plugins=vendor/plugins/crm_*

# Install required pancakes, syrups, bacon, and cucumber extras.
# -----------------------------------------------------
yum --quiet -y install $required_packages

# Install RVM if not installed
# -----------------------------------------------------
if ! (which rvm) then
  bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
fi

# Set up RVM as a function. This loads RVM into a shell session.
# -----------------------------------------------------
[[ -s "$HOME/.rvm/src/rvm/scripts/rvm" ]] && . "$HOME/.rvm/src/rvm/scripts/rvm"

# Install and use the configured ruby version
# -----------------------------------------------------
if ! (rvm list | grep $ruby_version); then rvm install $ruby_version; fi;
rvm use $ruby_version

if ! (gem list | grep "bundler"); then gem install bundler -v=$bundler_version --no-rdoc --no-ri; fi;

# Create Database Configuration File
# -----------------------------------------------------
cat << EOF > config/database.yml
test: &test
  adapter: postgresql
  database: crm_test
  username: postgres
  password: postgres
  host:     localhost
  port:     5432
  schema_search_path: public

cucumber:
  <<: *test
  database: crm_cucumber
EOF

# Create Crowd Settings File
# -----------------------------------------------------
cat << EOF > config/crowd_settings.yml
--- !map:HashWithIndifferentAccess
crowd:
  crowd_url: https://auth.crossroads.org.hk/crowd/services/SecurityServer
  crowd_app_name: rails-test
  crowd_app_pword: testing
  crowd_validation_factors_need_user_agent: false
  crowd_session_validationinterval: 0  # Set > 0 for authentication caching.
EOF

# Pull submodules from github read-only url.
# (Prevents needing to authenticate this machine)
# -----------------------------------------------------
sed -i s,git@github.com:,http://github.com/,g .git/config
git submodule init
git submodule update

# Run install scripts for each plugin in vendor/plugins.
# -----------------------------------------------------
for plugin_dir in $crm_plugins
do
  cd $plugin_dir

  if ( find -maxdepth 1 | grep "/install.rb" ) then
    echo "== Running install script for plugin: '$plugin_dir'..."
    ruby install.rb
  fi

  cd ../../..
done

# Install Bundle!
# -----------------------------------------------------
bundle install

# Create test and cucumber databases
# -----------------------------------------------------
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate db:migrate:plugins
RAILS_ENV=cucumber rake db:create
RAILS_ENV=cucumber rake db:migrate db:migrate:plugins

# Run RSpec tests and cucumbers for each crm_* plugin. (if they exist)
# -----------------------------------------------------
for plugin_dir in $crm_plugins
do
  echo "== Running RSpec tests and cucumbers for '$plugin_dir'..."
  cd $plugin_dir

  if ( find -maxdepth 1 | grep spec ) then
    RAILS_ENV=test rake bamboo:spec
  fi
  if ( find -maxdepth 1 | grep features ) then
    RAILS_ENV=test HEADLESS=true rake bamboo:cucumber
  fi

  cd ../../..
done

# Core FFCRM Specs and Cucumbers
# -----------------------------------------------------
RAILS_ENV=test rake bamboo:spec
RAILS_ENV=test HEADLESS=true rake bamboo:cucumber

# Drop Databases
# -----------------------------------------------------
RAILS_ENV=test rake db:drop
RAILS_ENV=cucumber rake db:drop
