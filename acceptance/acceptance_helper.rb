require File.expand_path("../../spec/spec_helper.rb", __FILE__)

require 'steak'
require 'capybara/rails'

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configuration.before(:each, :type => :acceptance) do
  PaperTrail.enabled = true
end
