# Project variables
# -----------------------------------------------------
ruby_version=1.9.2
bundler_version=1.0.0

ruby_packages="ruby ruby-devel gcc rubygems"
cucumber_packages="libxml2 libxml2-devel libxslt libxslt-devel xorg-x11-server-Xvfb firefox ImageMagick"
required_packages="$ruby_packages $cucumber_packages"

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
  adapter: mysql
  encoding: utf8
  database: crm_test
  username: root
  password: root
  socket: /var/lib/mysql/mysql.sock

cucumber:
  <<: *test
  database: crm_cucumber
EOF

# Pull submodules from github read-only url.
# (Prevents needing to authenticate this machine)
# -----------------------------------------------------
sed -i s,git@github.com:,http://github.com/,g .git/config
git submodule init
git submodule update

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
crm_plugins=vendor/plugins/crm_*
for plugin_dir in $crm_plugins
do
    echo "== Running RSpec tests and cucumbers for '$plugin_dir'..."
    cd $plugin_dir

    if ( find -maxdepth 1 | grep spec ) then
        rake bamboo:spec
    fi
    if ( find -maxdepth 1 | grep features ) then
        HEADLESS=true rake bamboo:cucumber
    fi

    cd ../../..
done

# Core FFCRM Specs and Cucumbers
# -----------------------------------------------------
RAILS_ENV=test rake bamboo:spec
RAILS_ENV=cucumber HEADLESS=true rake bamboo:cucumber

# Drop Databases
# -----------------------------------------------------
RAILS_ENV=test rake db:drop
RAILS_ENV=cucumber rake db:drop
