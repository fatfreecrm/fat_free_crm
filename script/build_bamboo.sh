# Install required pancakes
yum --quiet -y install ruby ruby-devel gcc rubygems
/usr/bin/gem install rake -v=0.8.7 --no-rdoc --no-ri
/usr/bin/gem install rails -v=2.3.8 --no-rdoc --no-ri
/usr/bin/gem install ci_reporter -v=1.6.2 --no-rdoc --no-ri

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
rm -rf ./spec/reports/*

RAILS_ENV=test rake db:create
RAILS_ENV=test rake gems:install
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake db:migrate:plugins
./script/spec --require `ruby -r 'rubygems' -e 'puts Gem.path.last'`/gems/ci_reporter-1.6.2/lib/ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec spec/
RAILS_ENV=test rake db:drop
