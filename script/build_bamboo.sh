# Install required pancakes
yum --quiet -y install ruby ruby-devel gcc rubygems
if ! (gem list | grep "rake" | grep "0.8.7"); then gem install rake -v=0.8.7 --no-rdoc --no-ri; fi;
if ! (gem list | grep "rails" | grep "2.3.8"); then gem install rails -v=2.3.8 --no-rdoc --no-ri; fi;
if ! (gem list | grep "ci_reporter" | grep "1.6.2"); then gem install ci_reporter -v=1.6.2 --no-rdoc --no-ri; fi;

# cucumber extras
yum --quiet -y install libxml2 libxml2-devel libxslt libxslt-devel xorg-x11-server-Xvfb firefox ImageMagick

# Create Database Configuration File
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
EOF

# Pull submodules from github read-only url. Prevents needing to authenticate this machine.
sed -i s,git@github.com:,http://github.com/,g .git/config
git submodule update

# fat free crm tests
RAILS_ENV=test rake db:create
RAILS_ENV=test rake gems:install
RAILS_ENV=cucumber rake gems:install
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake db:migrate:plugins
RAILS_ENV=test rake bamboo:spec
RAILS_ENV=cucumber rake db:test:purge db:migrate db:migrate:plugins
RAILS_ENV=cucumber HEADLESS=true rake bamboo:cucumber

# crm_super_tags tests
cd vendor/plugins/crm_super_tags
RAILS_ENV=test rake -f ../../../Rakefile bamboo:spec
RAILS_ENV=cucumber rake db:test:purge db:migrate db:migrate:plugins
HEADLESS=true RAILS_ENV=cucumber rake -f ../../../Rakefile bamboo:cucumber

# crm_merge_contacts tests
cd ../crm_merge_contacts
RAILS_ENV=test rake -f ../../../Rakefile bamboo:spec
RAILS_ENV=cucumber rake db:test:purge db:migrate db:migrate:plugins
HEADLESS=true RAILS_ENV=cucumber rake -f ../../../Rakefile bamboo:cucumber

# drop database
cd ../../../
RAILS_ENV=test rake db:drop
