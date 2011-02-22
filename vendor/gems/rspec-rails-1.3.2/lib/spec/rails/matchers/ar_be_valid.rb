if defined?(ActiveRecord::Base)
  module Spec
    module Rails
      module Matchers
        # :call-seq:
        #   response.should be_valid
        #   response.should_not be_valid
        def be_valid
          ::Spec::Matchers::Matcher.new :be_valid do
            match do |actual|
              actual.valid?
            end

            failure_message_for_should do |actual|
              if actual.respond_to?(:errors) && ActiveRecord::Errors === actual.errors
                "Expected #{actual.inspect} to be valid, but it was not\nErrors: " + actual.errors.full_messages.join(", ")            
              else
                "Expected #{actual.inspect} to be valid"
              end
            end
          end
        end

      end
    end
  end
end
