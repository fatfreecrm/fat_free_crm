set :user, "root"
set :use_sudo, false

set :deploy_to, "/opt/rails/#{application}-preview"

set :site_domain_name, "crm-preview.crossroadsint.org"
set :http_port, "8080"
set :ip_address, "10.0.1.86"

set :enable_ssl, false
#
# ssl setup
#
# set :enable_ssl, true
# set :ssl_ip_addr, "_default_"
# set :https_port, "8443"
#

server "10.0.1.86", :app, :web, :db, :primary => true

set :scm, :git
set :repository,  "git://github.com/crossroads/fat_free_crm.git"
set :deploy_via, :remote_cache
