require File.expand_path('../yum', __FILE__)

#
# Capistrano recipes for cold deployments
#
# Usage (add the following to your deploy.rb):
#
#    load 'recipes/stack'
#    set :gems_for_project, ""
#    ...
#
#    Then just run "cap deploy:cold" and this stack will hook into it
#

namespace :stack do

  # Override this if you don't want particular stack items
  desc "Setup operating system and rails environment"
  task :default do
    yum.update
    yum.install( {:base => packages_for_project}, :stable )
    gems

    deploy.setup
    shared.setup
  end

  desc "Install required gems"
  task :gems do
    run "rvmsudo gem install #{gems_for_project} --no-rdoc --no-ri"
  end

end

namespace 'shared' do

  desc "Setup shared directory"
  task :setup do
    sudo "mkdir -p #{deploy_to}/shared/config"
  end

  desc "Setting proper permissions on shared directory"
  task :permissions do
    sudo "chown -R apache:apache #{deploy_to}/shared/"
    #~ run "chmod -R 755 #{deploy_to}/shared/"
    # during deployments
    run "if [ -d #{release_path}/ ]; then sudo chown -R apache:apache #{release_path}/; fi"
    run "if [ -d #{release_path}/ ]; then sudo chmod -R 755 #{release_path}/; fi"
  end

end

#
# Hooks
#
before "deploy:cold",        "stack"
before "deploy:symlink",     "shared:permissions"
