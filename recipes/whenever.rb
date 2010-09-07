#
# Updates the crontab using wheneverize
#

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{current_path} && #{deploy_to}/shared/bundle/ruby/1.9.1/gems/whenever-0.5.0/bin/whenever --update-crontab #{application}"
  end
end
