set :rails_env, "staging"

set :app_server, "crm.ubxdstage.com"

role :app, app_server
role :web, app_server
role :db,  app_server, :primary => true

if ! ENV['BRANCH'].nil?
  set :branch, "#{ENV['BRANCH']}"
else
  set :branch, 'master'
end
