require 'capistrano/ext/multistage'
require 'capistrano_colors'
require 'bundler/capistrano'
load 'recipes/prompt'
load 'recipes/stack'
load 'recipes/passenger'
load 'recipes/whenever'

set :application, "fat-free-crm"
set :default_stage, "preview"
set :passenger_version, "2.2.15"
set :bundle_without, [:cucumber, :development, :test]

#
# To get going from scratch:
#
# cap deploy:cold
# cap crm:setup
# cap crm:demo
#
#

namespace :crm do

  desc "Load crm settings"
  task :settings do
    run "cd #{current_path} && RAILS_ENV=production rake crm:settings:load"
  end

  namespace :setup do

    desc "Prepare the database and load default application settings (destroys all data)"
    task :default do
      prompt_with_default("Username", :admin_username, "admin")
      prompt_with_default("Password", :admin_password, "admin")
      prompt_with_default("Email", :admin_email, "admin@crossroadsint.org")
      run "cd #{current_path} && RAILS_ENV=production rake crm:setup USERNAME=#{admin_username} PASSWORD=#{admin_password} EMAIL=#{admin_email} PROCEED=true"
    end

   desc "Creates an admin user"
    task :admin do
      prompt_with_default("Username", :admin_username, "admin")
      prompt_with_default("Password", :admin_password, "admin")
      prompt_with_default("Email", :admin_email, "admin@crossroadsint.org")
      run "cd #{current_path} && RAILS_ENV=production rake crm:setup:admin USERNAME=#{admin_username} PASSWORD=#{admin_password} EMAIL=#{admin_email}"
    end

  end

  desc "Load demo data (wipes database)"
  task :demo do
    run "cd #{current_path} && RAILS_ENV=production rake crm:demo:load"
  end

end

before 'deploy:finalize_update', 'git:submodules:update'
namespace :git do
  namespace :submodules do
    task :update do
      run "cd #{release_path} && git submodule init"
      run "cd #{release_path} && git submodule update"
    end
  end
end

after 'deploy:symlink', 'deploy:update_settings'
after 'deploy:migrate', 'deploy:migrate_plugins'
namespace :deploy do

  desc "Update settings file with server specific attributes (runs a server-side sed script)"
  task :update_settings do
    run "if [ -f #{shared_path}/settings.sed ]; then sed -i -f #{shared_path}/settings.sed #{release_path}/config/settings.yml; fi"
    crm.settings
    run "if [ ! -f #{shared_path}/log/dropbox.log ]; then touch #{shared_path}/log/dropbox.log; fi"
    #run "ln -sf #{shared_path}/log/dropbox.log  #{release_path}/log/dropbox.log"
  end

  desc "Migrate plugins"
  task :migrate_plugins do
    run "cd #{current_path} && RAILS_ENV=production rake db:migrate:plugins"
  end

end
