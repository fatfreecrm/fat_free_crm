set :application, "fat-free-crm"

require 'capistrano/ext/multistage'
require 'capistrano_colors'
load 'recipes/prompt'
load 'recipes/stack'
load 'recipes/passenger'

set :default_stage, "preview"
set :passenger_version, "2.2.15"

namespace :deploy do

  desc "Update gems using rake gems:install"
  task :install_gems do
    run "cd #{release_path} && RAILS_ENV=production rake gems:install"
  end

end

namespace :crm do

  desc "Load crm settings"
  task :settings do
    run "cd #{current_path} && RAILS_ENV=production rake crm:settings:load"
  end
  
  namespace :setup do

    desc "Load crm settings"
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

after "deploy:update_code", "deploy:install_gems"
after "deploy:update_code", "files:symlink_database_yml"
