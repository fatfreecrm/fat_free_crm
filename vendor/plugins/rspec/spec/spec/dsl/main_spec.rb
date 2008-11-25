require File.dirname(__FILE__) + '/../../spec_helper.rb'

module Spec
  module DSL
    describe Main do
      before(:each) do
        @main = Class.new do; include Main; end
      end

      [:describe, :context].each do |method|
        describe "##{method}" do
          it "should delegate to Spec::Example::ExampleGroupFactory.create_example_group" do
            block = lambda {}
            Spec::Example::ExampleGroupFactory.should_receive(:create_example_group).with(
              "The ExampleGroup", &block
            )
            @main.__send__ method, "The ExampleGroup", &block
          end
        end
      end
      
      [:share_examples_for, :shared_examples_for].each do |method|
        describe "##{method}" do
          it "should create a shared ExampleGroup" do
            block = lambda {}
            Spec::Example::SharedExampleGroup.should_receive(:register).with(
              "shared group", &block
            )
            @main.__send__ method, "shared group", &block
          end
        end
      end
    
      describe "#share_as" do
        class << self
          def next_group_name
            @group_number ||= 0
            @group_number += 1
            "Group#{@group_number}"
          end
        end
        
        def group_name
          @group_name ||= self.class.next_group_name
        end
        
        it "registers a shared ExampleGroup" do
          Spec::Example::SharedExampleGroup.should_receive(:register)
          group = @main.share_as group_name do end
        end
      
        it "creates a constant that points to a Module" do
          group = @main.share_as group_name do end
          Object.const_get(group_name).should equal(group)
        end
      
        it "complains if you pass it a not-constantizable name" do
          lambda do
            @group = @main.share_as "Non Constant" do end
          end.should raise_error(NameError, /The first argument to share_as must be a legal name for a constant/)
        end
      
      end
    end
  end
end
  