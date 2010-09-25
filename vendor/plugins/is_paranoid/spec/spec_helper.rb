require 'rubygems'
require 'bundler'

Bundler.setup :test

require 'stringio'
require 'yaml'
require 'rspec'
require 'active_record'
require 'is_paranoid'
require 'db_setup'

Rspec.configure do |c|

end
