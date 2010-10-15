#
# Capistrano recipes for cold deployments
#
# Usage (add the following to your deploy.rb):
#
#    load 'recipes/prompt'
#    load 'recipes/stack'
#    set :mysql_version, "2.8.1" (if different to default below)
#    set :gems_to_install, []
#    ...
#
#    Then just run "cap deploy:cold" and this stack will hook into it
#
# Depends on prompt.rb
#

#
# Useful commands
#
# cap stack - install operating system packages and setup rails folders
# cap update:os - runs yum update
# cap update:passenger - updates passenger
# cap files:set_permissions - sets permissions
#

#
# Defaults
#  - can be overriden or appended in deploy.rb but MUST come after load 'recipes/stack'
#
set :yum_packages_to_install, "aspell gcc gcc-c++ bzip2-devel zlib-devel make openssl-devel httpd-devel \
libstdc++-devel freeimage-devel clamav-devel mysql-devel readline-devel ruby ruby-rdoc ruby-ri ruby-irb \
rubygems ruby-devel mod_ssl git" # others include "memcached sphinx"
set :gems_to_install, {
  'bundler' => '1.0.0'
}

namespace :stack do

  # Override this if you don't want particular stack items
  desc "Setup operating system and rails environment"
  task :default do
    update.os
    install.default
    deploy.setup
    files.create_database_yml
    files.set_permissions
  end

end

namespace :install do

  desc "Setup operating system and rails environment"
  task :default do
    base
    rvm
    gems
    httpd
  end

  desc "Install base packages"
  task :base do
    run "yum clean all"
    run "yum -y install #{yum_packages_to_install}"
  end

  desc "Install rvm"
  task :rvm do
    run "if ! (which rvm); then curl -L http://bit.ly/rvm-install-system-wide | bash; fi"
    run "if ! (rvm list | grep #{ruby_version}); then rvm install #{ruby_version}; fi"
    run "rvm #{ruby_version} --passenger"
    run "rvm use #{ruby_version} --default"
  end

  desc "Install required gems"
  task :gems do
    gems_to_install.each do |name, version|
      run "gem install #{name} --no-rdoc --no-ri#{' --version '+ version unless (version.nil? or version == '') }"
    end
  end

  desc "Install Apache"
  task :httpd do
    run "yum -y install httpd httpd-devel apr apr-devel apr-util apr-util-devel"
    run "if [ `uname -m` == 'x86_64' ]; then yum -y remove apr-devel.i386 apr-util-devel.i386 httpd-devel.i386; fi"
    run "chkconfig httpd on"
    run "if [ -f /etc/httpd/conf.d/proxy_ajp.conf ]; then rm -rf /etc/httpd/conf.d/proxy_ajp.conf; fi"
  end

end

namespace :update do

  desc "Update Operating System"
  task :os do
    run "yum -y update"
  end

end

namespace 'files' do

  desc "Setting proper permissions on shared directory"
  task :set_permissions do
    run "chown -R apache:apache #{deploy_to}/shared/"
    run "chmod -R 755 #{deploy_to}/shared/"
    # during deployments
    run "if [ -d #{release_path}/ ]; then chown -R apache:apache #{release_path}/; fi"
    run "if [ -d #{release_path}/ ]; then chmod -R 755 #{release_path}/; fi"
  end

  desc "Create the mysql database and database.yml"
  task :create_database_yml do
    prompt_with_default("Database name", :db_name, "gh3_preview")
    prompt_with_default("Database username", :db_username, "gh3_preview")
    prompt_with_default("Database password", :db_password, "gh3_preview_password")
    prompt_with_default("Database host", :db_host, "localhost")
    prompt_with_default("Database port", :db_port, "3306")
    database_yml = <<-EOF
production:
  adapter: mysql
  encoding: utf8
  database: #{db_name}
  username: #{db_username}
  password: #{db_password}
  host:     #{db_host}
  port:     #{db_port}
  pool:     10
  timeout:  5
    EOF
    put database_yml, "#{deploy_to}/shared/database.yml"
    run("grep \"PASSWORD(\" /etc/mysql.d/grants.sql | cut -d \"'\" -f 6") { |channel, stream, data| set :pass, data }
    run "mysql -u root --password=#{pass.chomp} -e 'CREATE database #{db_name};'"
    run "mysql -u root --password=#{pass.chomp} -e \"GRANT ALL ON #{db_name}.* TO '#{db_username}'@'#{db_host}' IDENTIFIED BY '#{db_password}';\""
  end

  desc "Ensure the database.yml file is linked to current/config"
  task :symlink_database_yml do
    run "ln -sf #{deploy_to}/shared/database.yml  #{release_path}/config/database.yml"
  end

end

#
# Hooks
#
before "deploy:cold", "stack"
after "deploy:update_code", "files:symlink_database_yml"
before "deploy:symlink", "files:set_permissions"
