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

# Pull submodules from github read-only url. Prevents needing to authenticate this machine.

ls -l vendor/plugins
cat .gitmodules
sed -i s,git@github.com:,http://github.com/,g .gitmodules
cat .gitmodules
echo "submodule init"
git submodule init
echo "submodule update"
git submodule update

RAILS_ENV=test rake gems:install
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake db:migrate:plugins
./script/spec --require `ruby -r 'rubygems' -e 'puts Gem.path.last'`/gems/ci_reporter-1.6.2/lib/ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec spec/
# run submodule tests
RAILS_ENV=test rake db:drop
