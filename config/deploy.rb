set :stages, %w(staging production)
set :default_stage, "staging"

set :repository,  "git@github.com:unboxed/fat_free_crm.git"
set :application, "ffcrm"
set :user, "ffcrm"
set :deploy_to,   "/home/#{user}/#{application}"

require "bundler/capistrano"
begin
  require 'capistrano/ext/multistage'
rescue LoadError
  puts "Could not load capistrano multistage extension.  Make sure you have installed the capistrano-ext gem"
end

default_run_options[:pty] = true

set :scm, :git
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache
set :use_sudo, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  # Clean up old releases (by default keeps last 5)
  after "deploy:update_code", "deploy:cleanup"
  
  after "deploy:finalize_update", "deploy:symlink_configs"
  task :symlink_configs, :roles => :app do
    run "ln -fs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -fs #{shared_path}/config/settings.yml #{latest_release}/config/settings.yml"
    run "ln -fs #{shared_path}/config/ldap.yml #{latest_release}/config/ldap.yml"
    run "ln -fs #{shared_path}/config/ldap_attributes_map.yml #{latest_release}/config/ldap_attributes_map.yml"
  end
end