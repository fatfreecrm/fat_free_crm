module Caboose #:nodoc:
  module Acts #:nodoc:
    # Adds a wrapper find method which can identify :with_deleted or :only_deleted options
    # and would call the corresponding acts_as_paranoid finders find_with_deleted or
    # find_only_deleted methods.
    #
    # With this wrapper you can easily change from using this pattern:
    #
    #   if some_condition_enabling_access_to_deleted_records?
    #     @post = Post.find_with_deleted(params[:id])
    #   else
    #     @post = Post.find(params[:id])
    #   end
    #
    # to this:
    #
    #   @post = Post.find(params[:id], :with_deleted => some_condition_enabling_access_to_deleted_records?)
    #
    # Examples
    #
    #   class Widget < ActiveRecord::Base
    #     acts_as_paranoid
    #   end
    #
    #   Widget.find(:all)
    #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NULL
    #
    #   Widget.find(:all, :with_deleted => false)
    #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NULL
    #
    #   Widget.find_with_deleted(:all)
    #   # SELECT * FROM widgets
    #
    #   Widget.find(:all, :with_deleted => true)
    #   # SELECT * FROM widgets
    #
    #   Widget.find_only_deleted(:all)
    #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NOT NULL
    #
    #   Widget.find(:all, :only_deleted => true)
    #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NOT NULL
    #
    #   Widget.find(:all, :only_deleted => false)
    #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NULL
    #
    module ParanoidFindWrapper
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_paranoid_with_find_wrapper(options = {})
          unless paranoid? # don't let AR call this twice
            acts_as_paranoid_without_find_wrapper(options)
            class << self
              alias_method :find_without_find_wrapper, :find
              alias_method :validate_find_options_without_find_wrapper, :validate_find_options
            end
          end
          include InstanceMethods
        end
      end

      module InstanceMethods #:nodoc:
        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods
          # This is a wrapper for the regular "find" so you can pass acts_as_paranoid related
          # options and determine which finder to call.
          def find(*args)
            options = args.extract_options!
            # Determine who to call.
            finder_option = VALID_PARANOID_FIND_OPTIONS.detect { |key| options.delete(key) } || :without_find_wrapper
            finder_method = "find_#{finder_option}".to_sym
            # Put back the options in the args now that they don't include the extended keys.
            args << options
            send(finder_method, *args)
          end

          protected

            VALID_PARANOID_FIND_OPTIONS = [:with_deleted, :only_deleted]

            def validate_find_options(options) #:nodoc:
              cleaned_options = options.reject { |k, v| VALID_PARANOID_FIND_OPTIONS.include?(k) }
              validate_find_options_without_find_wrapper(cleaned_options)
            end
        end
      end
    end
  end
end
