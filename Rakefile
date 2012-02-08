# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake'
require 'bundler'

FatFreeCRM::Engine.load_tasks

Rake::Task[:default].clear
task :default => ['spec']


