# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Speed up hoptoad:deploy by not loading rails environment
if ARGV[0] == "hoptoad:deploy"
  require 'active_support/core_ext/string'
  require 'hoptoad_notifier'
  require File.join(File.dirname(__FILE__), 'config', 'initializers', 'hoptoad')
  require 'hoptoad_tasks'
  HoptoadTasks.deploy(:rails_env      => ENV['TO'],
                      :scm_revision   => ENV['REVISION'],
                      :scm_repository => ENV['REPO'],
                      :local_username => ENV['USER'],
                      :api_key        => ENV['API_KEY'])
  exit
end


require File.expand_path('../config/application', __FILE__)
require 'rake'

FatFreeCRM::Application.load_tasks

