require 'ransack/configuration'

module Ransack
  Configuration.class_eval do
    # Set default predicate options for predicate_select in form builder
    # This is ignored if any options are passed
    def default_predicates=(options)
      self.options[:default_predicates] = options
    end

    def ajax_options=(options)
      self.options[:ajax_options] = options
    end
  end
end