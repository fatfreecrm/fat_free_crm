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

# Add github key to known_hosts so we can fetch submodules
touch ~/.ssh/known_hosts
if ! (grep "github.com" ~/.ssh/known_hosts); then echo "github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> ~/.ssh/known_hosts; fi;
git submodule init
git submodule update

RAILS_ENV=test rake gems:install
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake db:migrate:plugins
./script/spec --require `ruby -r 'rubygems' -e 'puts Gem.path.last'`/gems/ci_reporter-1.6.2/lib/ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec spec/
RAILS_ENV=test rake db:drop
