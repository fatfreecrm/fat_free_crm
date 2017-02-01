# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(RSpec)
  require 'rspec/core/rake_task'

  namespace :spec do
    desc "Preparing test env db"
    task :preparedb do
      tmp_env = Rails.env
      Rails.env = "test"
      Rake::Task["ffcrm:config:copy_database_yml"].invoke
      puts "Preparing test database..."
      Rake::Task["db:schema:load"].invoke
      Rails.env = tmp_env
    end
  end
end
