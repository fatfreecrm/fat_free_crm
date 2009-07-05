$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'test/unit'
require 'rubygems'
require 'mocha'
require 'has_image'

RAILS_ROOT = File.join(File.dirname(__FILE__), '..', 'tmp')
