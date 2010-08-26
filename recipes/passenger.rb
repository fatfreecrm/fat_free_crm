#
# Adds passenger tasks to deploy stack
#
# Ensure the following variables are set in your deploy.rb
#   - set :enable_ssl, true
#   - set :ip_address, "127.0.0.1"
#   - set :site_domain_name, "www.example.com"
#   - set :passenger_version, "2.2.11"
#
# And that the following files exist:
#
# config/httpd.conf
# config/httpd-rails.conf
# config/passenger.conf
#
# Hooks transparently into stack.rb if it exists
#

namespace :deploy do

  %w(start stop restart reload).each do |t|
    desc "#{t.capitalize} passenger using httpd"
    task "#{t.to_sym}", :roles => :app, :except => { :no_release => true } do
      run "/etc/init.d/httpd #{t}"
    end
  end
  
end

namespace :passenger do

  desc "Symlinks files required for passenger"
  task :symlink, :roles => :app do
    run "sed -e 's,@DEPLOY_TO@,#{deploy_to},g' #{release_path}/config/httpd.conf > /etc/httpd/conf/httpd.conf"
    run "sed -e 's,@DEPLOY_TO@,#{deploy_to},g' -e 's,@IP_ADDR@,#{ip_address},g' -e 's,@SERVER_NAME@,#{site_domain_name},g' #{release_path}/config/httpd-rails.conf > /etc/httpd/conf.d/010-#{application}-#{stage}.conf"
    run "sed -e 's,@PASSENGER_VERSION@,#{passenger_version},g' #{release_path}/config/passenger.conf   > /etc/httpd/conf.d/passenger.conf"
  end
  
  desc "Install Passenger"
  task :install do
    run "gem install passenger --no-rdoc --no-ri --version #{passenger_version}"
    run "passenger-install-apache2-module --auto"
  end
 
  desc "Updates Passenger"
  task :update do
    install
  end

end

before "deploy:symlink", "passenger:symlink"
after("install:httpd", "passenger:install") if find_task('install:httpd')
