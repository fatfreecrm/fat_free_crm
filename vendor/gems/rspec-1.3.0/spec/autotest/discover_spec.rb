require 'autotest/autotest_helper'

describe Autotest::Rspec, "discovery" do
  it "adds the rspec autotest plugin" do
    Autotest.should_receive(:add_discovery)
    load File.expand_path("../../../lib/autotest/discover.rb", __FILE__)
  end
end  
