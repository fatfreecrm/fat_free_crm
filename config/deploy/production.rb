set :rails_env, "production"

set :rails_server, "prod2.unboxedconsulting.com"

role :app, rails_server
role :web, rails_server
role :db,  rails_server, :primary => true

if ENV['TAG'].nil?
  puts "No tag specified for production deploy.  Set the TAG env variable to the tag to deploy."
  puts "e.g. TAG='REL-1.2' cap production deploy:migrations"
  exit 1
else
  set :branch, "#{ENV['TAG']}"
end