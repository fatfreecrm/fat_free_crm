module Spec
  module Matchers
    class RaiseException #:nodoc:
      def initialize(expected_exception_or_message=Exception, expected_message=nil, &block)
        @block = block
        @actual_exception = nil
        case expected_exception_or_message
        when String, Regexp
          @expected_exception, @expected_message = Exception, expected_exception_or_message
        else
          @expected_exception, @expected_message = expected_exception_or_message, expected_message
        end
      end

      def matches?(given_proc)
        @raised_expected_exception = false
        @with_expected_message = false
        @eval_block = false
        @eval_block_passed = false
        begin
          given_proc.call
        rescue @expected_exception => @actual_exception
          @raised_expected_exception = true
          @with_expected_message = verify_message
        rescue Exception => @actual_exception
          # This clause should be empty, but rcov will not report it as covered
          # unless something (anything) is executed within the clause
          rcov_exception_report = "http://eigenclass.org/hiki.rb?rcov-0.8.0"
        end

        unless negative_expectation?
          eval_block if @raised_expected_exception && @with_expected_message && @block
        end

        (@raised_expected_exception & @with_expected_message) ? (@eval_block ? @eval_block_passed : true) : false
      end

      def eval_block
        @eval_block = true
        begin
          @block[@actual_exception]
          @eval_block_passed = true
        rescue Exception => err
          @actual_exception = err
        end
      end

      def verify_message
        case @expected_message
        when nil
          true
        when Regexp
          @expected_message =~ @actual_exception.message
        else
          @expected_message == @actual_exception.message
        end
      end

      def failure_message_for_should
        @eval_block ? @actual_exception.message : "expected #{expected_exception}#{given_exception}"
      end

      def failure_message_for_should_not
        "expected no #{expected_exception}#{given_exception}"
      end

      def description
        "raise #{expected_exception}"
      end

      private
        def expected_exception
          case @expected_message
          when nil
            @expected_exception
          when Regexp
            "#{@expected_exception} with message matching #{@expected_message.inspect}"
          else
            "#{@expected_exception} with #{@expected_message.inspect}"
          end
        end

        def given_exception
          @actual_exception.nil? ? " but nothing was raised" : ", got #{@actual_exception.inspect}"
        end

        def negative_expectation?
          # YES - I'm a bad person... help me find a better way - ryand
          caller.first(3).find { |s| s =~ /should_not/ }
        end
    end

    # :call-seq:
    #   should raise_exception()
    #   should raise_exception(NamedError)
    #   should raise_exception(NamedError, String)
    #   should raise_exception(NamedError, Regexp)
    #   should raise_exception() { |exception| ... }
    #   should raise_exception(NamedError) { |exception| ... }
    #   should raise_exception(NamedError, String) { |exception| ... }
    #   should raise_exception(NamedError, Regexp) { |exception| ... }
    #   should_not raise_exception()
    #   should_not raise_exception(NamedError)
    #   should_not raise_exception(NamedError, String)
    #   should_not raise_exception(NamedError, Regexp)
    #
    # With no args, matches if any exception is raised.
    # With a named exception, matches only if that specific exception is raised.
    # With a named exception and messsage specified as a String, matches only if both match.
    # With a named exception and messsage specified as a Regexp, matches only if both match.
    # Pass an optional block to perform extra verifications on the exception matched
    #
    # == Examples
    #
    #   lambda { do_something_risky }.should raise_exception
    #   lambda { do_something_risky }.should raise_exception(PoorRiskDecisionError)
    #   lambda { do_something_risky }.should raise_exception(PoorRiskDecisionError) { |exception| exception.data.should == 42 }
    #   lambda { do_something_risky }.should raise_exception(PoorRiskDecisionError, "that was too risky")
    #   lambda { do_something_risky }.should raise_exception(PoorRiskDecisionError, /oo ri/)
    #
    #   lambda { do_something_risky }.should_not raise_exception
    #   lambda { do_something_risky }.should_not raise_exception(PoorRiskDecisionError)
    #   lambda { do_something_risky }.should_not raise_exception(PoorRiskDecisionError, "that was too risky")
    #   lambda { do_something_risky }.should_not raise_exception(PoorRiskDecisionError, /oo ri/)
    def raise_exception(exception=Exception, message=nil, &block)
      Matchers::RaiseException.new(exception, message, &block)
    end

    alias_method :raise_error, :raise_exception
  end
end
