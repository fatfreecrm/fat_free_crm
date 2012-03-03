#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler.require :default, :development
require 'rails/all'

Combustion::Application.load_tasks

task :environment do
  Combustion.initialize!
end

task :default => ['spec']
