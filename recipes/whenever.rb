#
# Updates the crontab using wheneverize
#

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{current_path} && rvmsudo bundle exec whenever --update-crontab #{application}"
  end
  
  desc "Remove the application entries from crontab"
  task :disable_crontab, :roles => :db do
    run "cd #{current_path} && rvmsudo bundle exec whenever --clear-crontab #{application}"
  end
end
