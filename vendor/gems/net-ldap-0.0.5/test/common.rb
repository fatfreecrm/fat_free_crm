# Add 'lib' to load path.
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'rubygems'
require 'test/unit'

require 'net/ldap'
