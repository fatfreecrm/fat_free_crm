set :rails_env, "production"

set :app_server, "extranet.unboxedconsulting.com"

role :app, app_server
role :web, app_server
role :db,  app_server, :primary => true

if ENV['TAG'].nil?
  puts "No tag specified for production deploy.  Set the TAG env variable to the tag to deploy."
  puts "e.g. TAG='REL-1.2' cap production deploy:migrations"
  exit 1
else
  set :branch, "#{ENV['TAG']}"
end
