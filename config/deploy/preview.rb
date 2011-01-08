set :user, "root"
set :use_sudo, false

set :ip_address, "10.0.1.86"
set :site_domain_name, "crm-preview.crossroadsint.org"

server ip_address, :app, :web, :db, :primary => true

set :deploy_to, "/opt/rails/#{application}-#{stage}"

set :branch, "master"
