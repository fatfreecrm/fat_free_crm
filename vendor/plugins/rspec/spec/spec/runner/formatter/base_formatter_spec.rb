require File.dirname(__FILE__) + "/../../../spec_helper"

module Spec
  module Runner
    module Formatter
      describe BaseFormatter do
        before :each do
          @options, @where = nil, nil
          @formatter = BaseFormatter.new(@options, @where)
        end
        
        class HaveInterfaceMatcher
          def initialize(method)
            @method = method
          end
          
          attr_reader :object
          attr_reader :method
          
          def matches?(object)
            @object = object
            object.respond_to?(@method)
          end
          
          def with(arity)
            WithArity.new(self, @method, arity)
          end
          
          class WithArity
            def initialize(matcher, method, arity)
              @have_matcher = matcher
              @method = method
              @arity  = arity
            end
            
            def matches?(an_object)
              @have_matcher.matches?(an_object) && real_arity == @arity
            end
            
            def failure_message
              "#{@have_matcher} should have method :#{@method} with #{argument_arity}, but it had #{real_arity}"
            end
            
            def arguments
              self
            end
            
            alias_method :argument, :arguments
            
          private
            
            def real_arity
              @have_matcher.object.method(@method).arity
            end
            
            def argument_arity
              if @arity == 1
                "1 argument"
              else
                "#{@arity} arguments"
              end
            end
          end
        end
        
        def have_interface_for(method)
          HaveInterfaceMatcher.new(method)
        end
        
        it "should have start as an interface with one argument"do
          @formatter.should have_interface_for(:start).with(1).argument
        end
        
        it "should have add_example_group as an interface with one argument" do
          @formatter.should have_interface_for(:add_example_group).with(1).argument
        end
        
        it "should have example_started as an interface with one argument" do
          @formatter.should have_interface_for(:example_started).with(1).argument
        end
        
        it "should have example_failed as an interface with three arguments" do
          @formatter.should have_interface_for(:example_failed).with(3).arguments
        end
        
        it "should have example_pending as an interface with three arguments" do
          @formatter.should have_interface_for(:example_pending).with(3).arguments
        end
        
        it "should have start_dump as an interface with zero arguments" do
          @formatter.should have_interface_for(:start_dump).with(0).arguments
        end
        
        it "should have dump_failure as an interface with two arguments" do
          @formatter.should have_interface_for(:dump_failure).with(2).arguments
        end
        
        it "should have dump_summary as an interface with two arguments" do
          @formatter.should have_interface_for(:dump_failure).with(2).arguments
        end

        it "should have dump_pending as an interface with zero arguments" do
          @formatter.should have_interface_for(:dump_pending).with(0).arguments
        end

        it "should have close  as an interface with zero arguments" do
          @formatter.should have_interface_for(:close).with(0).arguments
        end
      end
    end
  end
end
