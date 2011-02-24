set :stages, %w(staging production)
set :default_stage, "staging"

set :application, "ffcrm"
set :user, "ffcrm"

set :deploy_to,   "/home/#{user}/#{application}"

begin
  require 'capistrano/ext/multistage'
rescue LoadError
  puts "Could not load capistrano multistage extension.  Make sure you have installed the capistrano-ext gem"
  exit 1
end

default_run_options[:pty] = true

set :scm, :git
set :repository, "git@code.unboxedconsulting.com:#{application}.git"
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache

set :use_sudo, false

namespace :deploy do

  after "deploy:setup", "deploy:initial_setup"
  task :initial_setup do
    run "mkdir -p #{shared_path}/config"
    put File.read(File.join(File.expand_path(File.dirname(__FILE__)), "database.yml.example")), "#{shared_path}/config/database.yml", :mode => 0600
    put File.read(File.join(File.expand_path(File.dirname(__FILE__)), "ldap.yml.example")), "#{shared_path}/config/ldap.yml", :mode => 0600
  end

  after "deploy:setup", "deploy:create_asset_dirs"
  task :create_asset_dirs do
    run "mkdir -p #{shared_path}/avatars"
  end

  after "deploy:finalize_update", "deploy:symlink_configs"
  task :symlink_configs do
    run "ln -fs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -fs #{shared_path}/config/ldap.yml #{latest_release}/config/ldap.yml"
    run "rm -rf #{latest_release}/public/avatars && ln -s #{shared_path}/avatars #{latest_release}/public/avatars"
  end

  # Clean up old releases (by default keeps last 5)
  after "deploy:update_code", "deploy:cleanup"

  after "deploy:migrate", "deploy:load_settings"
  desc "Load in all the settings from config/settings.yml"
  task :load_settings do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake crm:settings:load"
  end

  task :start do
  end

  desc "Restart the app"
  task :restart do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop do
  end

  namespace :web do

    before "deploy", "deploy:web:disable"
    before "deploy:migrations", "deploy:web:disable"

    # desc "Present a maintenance page to visitors."
    # task :disable, :roles => :web, :except => { :no_release => true } do
    #   on_rollback { run "rm #{shared_path}/system/maintenance.html" }
    #
    #   run "cp #{current_path}/public/maintenance/maintenance.html #{shared_path}/system/"
    # end

    after "deploy", "deploy:web:enable"
    after "deploy:migrations", "deploy:web:enable"
    # Default web:enable task is fine

  end
end
