# Install required pancakes, syrups and bacon
# -----------------------------------------------------
yum --quiet -y install ruby ruby-devel gcc rubygems
if ! (gem list | grep "bundler"); then gem install bundler -v=1.0.0 --no-rdoc --no-ri; fi;

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
PLUGINS=vendor/plugins/crm_*
for f in $PLUGINS
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
