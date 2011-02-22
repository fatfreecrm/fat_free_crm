# -*- ruby -*-

require 'rubygems'
require 'hoe'

# Add 'lib' to load path.
$LOAD_PATH.unshift( "#{File.dirname(__FILE__)}/lib" )

# Pull in local 'net/ldap' as opposed to an installed version.
require 'net/ldap'

Hoe.new('net-ldap', Net::LDAP::VERSION) do |p|
	p.rubyforge_name = 'net-ldap'
	p.developer('Francis Cianfrocca', 'garbagecat10@gmail.com')
	p.developer('Emiel van de Laar', 'gemiel@gmail.com')
end

# vim: syntax=Ruby
