module Nexx
  module AdvancedErrors
    module FullMessages
      def full_messages_with_ignore_attribute
        error = ActiveRecord::Errors.new @base
        self.each do |attribute, message|
          unless message.match(/^\^/)
            error.add attribute, message
          else
            error.add_to_base message[1..message.length] #Adding to base will mean that the attribute will not be displayed
          end
        end
        error.full_messages_without_ignore_attribute
      end
  
      def self.included(base)
        base.class_eval do
          alias_method :full_messages_without_ignore_attribute, :full_messages
          alias_method :full_messages, :full_messages_with_ignore_attribute
        end
      end
    end
  end
end