ruby_version=1.9.2
bundler_version=1.0.0

# Install required pancakes, syrups and bacon
# -----------------------------------------------------
yum --quiet -y install ruby ruby-devel gcc rubygems

# Install RVM and 1.9.2 if not already installed.
# -----------------------------------------------------
if ! (which rvm); then 
 bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
fi
 
if ! (rvm list | grep $ruby_version); then rvm install $ruby_version; fi;

# Use the installed ruby version.
# -----------------------------------------------------
rvm use $ruby_version

if ! (gem list | grep "bundler"); then gem install bundler -v=$bundler_version --no-rdoc --no-ri; fi;

# cucumber extras
# -----------------------------------------------------
yum --quiet -y install libxml2 libxml2-devel libxslt libxslt-devel xorg-x11-server-Xvfb firefox ImageMagick

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
git submodule update

# Install Bundle!
# -----------------------------------------------------
bundle install

# Create test and cucumber databases
# -----------------------------------------------------
RAILS_ENV=test rake db:create
RAILS_ENV=cucumber rake db:create
RAILS_ENV=test rake db:migrate db:migrate:plugins
RAILS_ENV=cucumber rake db:migrate db:migrate:plugins

# Run RSpec tests and cucumbers for each crm_* plugin.
# -----------------------------------------------------
CRMPLUGINS=vendor/plugins/crm_*
for f in $CRMPLUGINS
do
    echo "== Running RSpec tests and cucumbers for '$f'..."
    cd $f
    rake bamboo:spec
    rake bamboo:cucumber
    cd ../../..
done

# Core FFCRM Specs and Cucumbers
# -----------------------------------------------------
rake bamboo:spec
rake bamboo:cucumber

# Drop Databases
# -----------------------------------------------------
RAILS_ENV=test rake db:drop
RAILS_ENV=cucumber rake db:drop
