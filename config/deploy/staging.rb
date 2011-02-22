set :rails_env, "production"

set :app_server, "stage.unboxedconsulting.com"

role :app, app_server
role :web, app_server
role :db,  app_server, :primary => true

set :branch, 'master'
