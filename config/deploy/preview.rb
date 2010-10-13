set :user, "root"
set :use_sudo, false

set :ip_address, "10.0.1.86"
set :site_domain_name, "crm-preview.crossroadsint.org"

server "10.0.1.86", :app, :web, :db, :primary => true

set :deploy_to, "/opt/rails/#{application}-preview"

set :scm, :git
set :repository, "git://github.com/crossroads/fat_free_crm.git"
set :branch, "master"
set :deploy_via, :remote_cache
