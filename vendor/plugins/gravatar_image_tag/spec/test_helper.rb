require 'rubygems'
require 'spec'
require 'active_support'
require 'action_view'
require 'digest/md5'
require 'uri'

Spec::Runner.configure do |config|
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
