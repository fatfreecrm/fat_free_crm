# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'bundler'

FatFreeCRM::Application.load_tasks

Rake::Task[:default].clear

namespace :spec do
  desc "Preparing test env"
  task :prepare do
    tmp_env = Rails.env
    Rails.env = "test"
    Rake::Task["crm:copy_default_config"].invoke
    puts "Running initial migrations..."
    puts "Preparing test database..."
    Rake::Task["db:schema:load"].invoke
    Rake::Task["crm:settings:load"].invoke
    Rails.env = tmp_env
  end
end

Rake::Task["spec"].prerequisites.clear
Rake::Task["spec"].prerequisites.push("spec:prepare")
task :default => ['spec']

