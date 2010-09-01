# Install required pancakes
yum --quiet -y install ruby ruby-devel gcc rubygems
if ! (gem list | grep "rake" | grep "0.8.7"); then gem install rake -v=0.8.7 --no-rdoc --no-ri; fi;
if ! (gem list | grep "rails" | grep "2.3.8"); then gem install rails -v=2.3.8 --no-rdoc --no-ri; fi;
if ! (gem list | grep "ci_reporter" | grep "1.6.2"); then gem install ci_reporter -v=1.6.2 --no-rdoc --no-ri; fi;
#if ! (gem list | grep "cucumber-rails" | grep "0.3.2"); then gem install cucumber-rails -v=0.3.2 --no-rdoc --no-ri; fi;
#if ! (gem list | grep "database_cleaner" | grep "0.5.0"); then gem install database_cleaner -v=0.5.0 --no-rdoc --no-ri; fi;
#if ! (gem list | grep "capybara" | grep "0.3.9"); then gem install capybara -v=0.3.9 --no-rdoc --no-ri; fi;

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
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake db:migrate:plugins
RAILS_ENV=test rake bamboo

# crm_super_tags tests
cd vendor/plugins/crm_super_tags && RAILS_ENV=test rake bamboo
# cucumbers need cucumber env
#GEM_PATH=`ruby -r 'rubygems' -e 'puts Gem.path.last'`
#ruby -r $GEM_PATH/gems/ci_reporter-1.6.2/lib/ci/reporter/rake/cucumber_loader -S cucumber --format CI::Reporter::Cucumber

# crm_merge_contacts tests
cd vendor/plugins/crm_merge_contacts && RAILS_ENV=test rake bamboo
# cucumbers need cucumber env

# drop database
cd ../../../
RAILS_ENV=test rake db:drop
