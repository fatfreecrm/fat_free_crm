#
# Adds passenger tasks to deploy stack
#
# Ensure the following variables are set in your deploy.rb
#   - set :ip_address, "127.0.0.1"
#   - set :site_domain_name, "www.example.com"
#   - set :passenger_version, "3.0.0"
#
# And that the following files exist:
#
# config/httpd-rails.conf
# config/passenger.conf
#

namespace :deploy do

  %w(start stop restart reload).each do |t|
    desc "#{t.capitalize} passenger using httpd"
    task "#{t.to_sym}", :roles => :app, :except => { :no_release => true } do
      sudo "/etc/init.d/httpd #{t}"
    end
  end

end

namespace :passenger do

  desc "Install Passenger"
  task :install, :roles => :web do
    install_deps

    run "if ! (gem list | grep passenger-#{passenger_version}); then rvmsudo gem install passenger -v #{passenger_version} --no-rdoc --no-ri; fi"
    run "rvmsudo passenger-install-apache2-module --auto"
  end

  task :install_deps, :roles => :web do
    yum.install( {:base => %w(curl-devel httpd-devel apr-devel)}, :stable )
  end

  desc "Apache config files"
  task :config, :roles => :web do
    sudo "cp -f #{release_path}/config/httpd-rails.conf /etc/httpd/sites-enabled/010-#{application}-#{stage}.conf"
    sudo "sed -i -e 's,@DEPLOY_TO@,#{deploy_to},g' -e 's,@IP_ADDR@,#{ip_address},g' -e 's,@SERVER_NAME@,#{site_domain_name},g' /etc/httpd/sites-enabled/010-#{application}-#{stage}.conf"
    sudo "cp -f #{release_path}/config/passenger.conf /etc/httpd/mods-enabled/passenger.conf"
    sudo "sed -i -e 's,@RVM_RUBY_STRING@,#{rvm_ruby_string},g' -e 's,@PASSENGER_VERSION@,#{passenger_version},g' /etc/httpd/mods-enabled/passenger.conf"
  end

end

before "deploy:cold",        "passenger:install"
after  "deploy:update_code", "passenger:config"
