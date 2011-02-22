module Spec
  module Matchers
    class Matcher
      include Spec::Matchers::InstanceExec
      include Spec::Matchers::Pretty
      include Spec::Matchers

      attr_reader :expected, :actual

      def initialize(name, *expected, &declarations)
        @name     = name
        @expected = expected
        @actual   = nil
        @diffable = false
        @expected_exception = nil
        @messages = {
          :description => lambda {"#{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should => lambda {|actual| "expected #{actual.inspect} to #{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should_not => lambda {|actual| "expected #{actual.inspect} not to #{name_to_sentence}#{expected_to_sentence}"}
        }
        making_declared_methods_public do
          instance_exec(*@expected, &declarations)
        end
      end

      #Used internally by objects returns by +should+ and +should_not+.
      def matches?(actual)
        @actual = actual
        if @expected_exception
          begin
            instance_exec(actual, &@match_block)
            true
          rescue @expected_exception
            false
          end
        else
          begin
            instance_exec(actual, &@match_block)
          rescue Spec::Expectations::ExpectationNotMetError
            false
          end
        end
      end

      # See Spec::Matchers
      def match(&block)
        @match_block = block
      end

      # See Spec::Matchers
      def match_unless_raises(exception=Exception, &block)
        @expected_exception = exception
        match(&block)
      end

      # See Spec::Matchers
      def failure_message_for_should(&block)
        cache_or_call_cached(:failure_message_for_should, &block)
      end

      # See Spec::Matchers
      def failure_message_for_should_not(&block)
        cache_or_call_cached(:failure_message_for_should_not, &block)
      end

      # See Spec::Matchers
      def description(&block)
        cache_or_call_cached(:description, &block)
      end

      #Used internally by objects returns by +should+ and +should_not+.
      def diffable?
        @diffable
      end

      # See Spec::Matchers
      def diffable
        @diffable = true
      end
      
      # See Spec::Matchers
      def chain(method, &block)
        self.class.class_eval do
          define_method method do |*args|
            block.call(*args)
            self
          end
        end
      end

    private

      def making_declared_methods_public # :nodoc:
        # Our home-grown instance_exec in ruby 1.8.6 results in any methods
        # declared in the block eval'd by instance_exec in the block to which we
        # are yielding here are scoped private. This is NOT the case for Ruby
        # 1.8.7 or 1.9.
        #
        # Also, due some crazy scoping that I don't understand, these methods
        # are actually available in the specs (something about the matcher being
        # defined in the scope of Spec::Matchers or within an example), so not
        # doing the following will not cause specs to fail, but they *will*
        # cause features to fail and that will make users unhappy. So don't.
        orig_private_methods = private_methods
        yield
        st = (class << self; self; end)
        (private_methods - orig_private_methods).each {|m| st.__send__ :public, m}
      end

      def cache_or_call_cached(key, &block)
        block ? cache(key, &block) : call_cached(key)
      end

      def cache(key, &block)
        @messages[key] = block
      end

      def call_cached(key)
        @messages[key].arity == 1 ? @messages[key].call(@actual) : @messages[key].call
      end

      def name_to_sentence
        split_words(@name)
      end

      def expected_to_sentence
        to_sentence(@expected)
      end

    end
  end
end
