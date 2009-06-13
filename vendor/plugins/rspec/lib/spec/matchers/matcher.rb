module Spec
  module Matchers
    class Matcher
      include Spec::Matchers::Pretty
      
      attr_reader :expected, :actual
      
      def initialize(name, *expected, &declarations)
        @name = name
        @expected = expected
        @declarations = declarations
        @diffable = false
        @messages = {
          :description => lambda {"#{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should => lambda {|actual| "expected #{actual.inspect} to #{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should_not => lambda {|actual| "expected #{actual.inspect} not to #{name_to_sentence}#{expected_to_sentence}"}
        }
      end
      
      def matches?(actual)
        @actual = actual
        instance_exec(*@expected, &@declarations)
        instance_exec(@actual,    &@match_block)
      end
      
      def description(&block)
        cache_or_call_cached(:description, &block)
      end
      
      def failure_message_for_should(&block)
        cache_or_call_cached(:failure_message_for_should, @actual, &block)
      end
      
      def failure_message_for_should_not(&block)
        cache_or_call_cached(:failure_message_for_should_not, @actual, &block)
      end
      
      def match(&block)
        @match_block = block
      end
      
      def diffable?
        @diffable
      end
      
      def diffable
        @diffable = true
      end
      
    private

      def cache_or_call_cached(key, actual=nil, &block)
        block ? @messages[key] = block : 
                actual.nil? ? @messages[key].call : @messages[key].call(actual)
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