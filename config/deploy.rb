require 'capistrano_colors'
require 'capistrano/ext/multistage'
require 'rvm/capistrano'
require 'bundler/capistrano'

load 'recipes/prompt.rb'
load 'recipes/stack.rb'
load 'recipes/rvm.rb'
load 'recipes/passenger.rb'
load 'recipes/postgresql.rb'
load 'recipes/whenever.rb'

default_run_options[:pty] = true

set :application, "ffcrm"
set :domain, "crossroadsint.org"
set :default_stage, "preview"
set :keep_releases, 3

set :bundle_without, [:cucumber, :development, :test]
set :bundle_flags, "--quiet"

set :scm, :git
set :repository, "git://github.com/crossroads/fat_free_crm.git"
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

set :packages_for_project, %w(ImageMagick-devel)
set :gems_for_project, "bundler"

set :rvm_ruby_string, "1.9.2"
set :passenger_version, "3.0.0"

#
# To get going from scratch:
#
# cap deploy:cold
# cap crm:setup
# cap crm:demo
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

  namespace :crossroads do
    desc "Seed crossroads data (tags and customfields, etc.)"
    task :seed do
      run "cd #{current_path} && RAILS_ENV=production rake crm:crossroads:seed"
    end
  end

end

after 'deploy:migrate', 'deploy:update_settings'
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

before 'deploy:cold', 'stack:ssh-keygen'
namespace :stack do
  desc "Generate ssh key for adding to github public keys"
  task 'ssh-keygen' do
    puts; puts
    puts "====================================================================="
    puts "If capistrano stops here then paste the following key into github and"
    puts "run \"cap deploy:cold\" again"
    puts "====================================================================="
    puts; puts
    run "if ! (ls /root/.ssh/id_rsa); then (ssh-keygen -N '' -t rsa -q -f /root/.ssh/id_rsa && cat /root/.ssh/id_rsa.pub) && exit 1; fi"
  end
end
