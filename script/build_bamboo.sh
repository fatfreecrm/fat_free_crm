# Install required pancakes
yum --quiet -y install ruby ruby-devel gcc rubygems
if ! (gem list | grep "rake" | grep "0.8.7"); then gem install rake -v=0.8.7 --no-rdoc --no-ri; fi;
if ! (gem list | grep "rails" | grep "2.3.8"); then gem install rails -v=2.3.8 --no-rdoc --no-ri; fi;
if ! (gem list | grep "ci_reporter" | grep "1.6.2"); then gem install ci_reporter -v=1.6.2 --no-rdoc --no-ri; fi;

# Create Database Configuration File
cat << EOF > config/database.yml
test:
  adapter: mysql
  encoding: utf8
  database: crm_test
  username: root
  password: root
  socket: /var/lib/mysql/mysql.sock
EOF

# Cleanup after the previous run.
ls ./spec/reports/ # stub to tell us if old files are still there REMOVE
rm -rf ./spec/reports/*

git submodule init
git submodule update
RAILS_ENV=test rake gems:install
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake db:migrate:plugins
echo "Running tests..."
./script/spec --require `ruby -r 'rubygems' -e 'puts Gem.path.last'`/gems/ci_reporter-1.6.2/lib/ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec spec/
RAILS_ENV=test rake db:drop
