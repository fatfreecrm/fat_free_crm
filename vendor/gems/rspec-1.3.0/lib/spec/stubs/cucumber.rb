# This plugs RSpec's mocking/stubbing framework into cucumber
require 'spec/mocks'
Before {$rspec_mocks ||= Spec::Mocks::Space.new}
After  {$rspec_mocks.reset_all}
World(Spec::Mocks::ExampleMethods)
