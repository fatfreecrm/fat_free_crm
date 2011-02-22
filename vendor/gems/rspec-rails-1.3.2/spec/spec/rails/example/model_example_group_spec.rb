require 'spec_helper'

module Spec
  module Rails
    module Example
      describe ModelExampleGroup do
        accesses_configured_helper_methods
        
        if defined?(ActiveRecord::TestCase)
          it "derives from ActiveRecord::TestCase" do
            group = describe("foo", :type => :model) do; end
            group.ancestors.should include(ActiveRecord::TestCase)
          end
        else
          it "derives from ActiveSupport::TestCase" do
            group = describe("foo", :type => :model) do; end
            group.ancestors.should include(ActiveSupport::TestCase)
          end
        end
        
        it "clears its name from the description" do
          group = describe("foo", :type => :model) do
            $nested_group = describe("bar") do
            end
          end
          group.description.to_s.should == "foo"
          $nested_group.description.to_s.should == "foo bar"
        end
      end
    end
  end
end