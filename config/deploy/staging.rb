set :rails_env, "staging"

set :rails_server, "stage3.unboxedconsulting.com"

role :app, rails_server
role :web, rails_server
role :db,  rails_server, :primary => true

if ENV['BRANCH'].nil?
  set :branch, "master"
else
  set :branch, "#{ENV['BRANCH']}"
end