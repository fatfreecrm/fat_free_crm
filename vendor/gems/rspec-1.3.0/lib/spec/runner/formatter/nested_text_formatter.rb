require 'spec/runner/formatter/base_text_formatter'

module Spec
  module Runner
    module Formatter
      class NestedTextFormatter < BaseTextFormatter

        INDENT = '  '

        def initialize(options, where)
          super
          @last_nested_descriptions = []
        end

        def example_group_started(example_group)
          super

          example_group.nested_descriptions.each_with_index do |nested_description, i|
            unless example_group.nested_descriptions[0..i] == @last_nested_descriptions[0..i]
              output.puts "#{INDENT*i}#{nested_description}"
            end
          end

          @last_nested_descriptions = example_group.nested_descriptions
        end

        def example_failed(example, counter, failure)
          output.puts(red("#{current_indentation}#{example.description} (FAILED - #{counter})"))
          output.flush
        end

        def example_passed(example)
          message = "#{current_indentation}#{example.description}"
          output.puts green(message)
          output.flush
        end

        def example_pending(example, message, deprecated_pending_location=nil)
          super
          output.puts yellow("#{current_indentation}#{example.description} (PENDING: #{message})")
          output.flush
        end

        def current_indentation
          INDENT*@last_nested_descriptions.length
        end
      end
    end
  end
end
