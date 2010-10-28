set :user, "root"
set :use_sudo, false

set :ip_address, "10.0.1.86"
set :site_domain_name, "crm-preview.crossroadsint.org"

server "10.0.1.86", :app, :web, :db, :primary => true

set :deploy_to, "/opt/rails/#{application}-preview"

set :branch, "master"

set :db_name, "crm_preview"
set :db_user, "crm_preview"
set :db_password, "crm_preview_password"
set :db_host, "localhost"
set :db_port, "5432"
