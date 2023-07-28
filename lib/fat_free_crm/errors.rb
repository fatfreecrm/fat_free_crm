# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCRM
  module ActiveModel
    module Errors
      # Override ActiveModel::Errors#each so we could display validation
      # errors as is without rendering the attribute name. Simply place
      # a caret as the first character of the error message.
      #
      # This feature was handled by 'advanced_errors' plugin in Rails 2.x
      # version of Fat Free CRM.
      #----------------------------------------------------------------------------
      def self.included(base)
        base.class_eval do
          alias_method :each, :each_with_explicit_error
        end
      end

      def each_with_explicit_error(&block)
        @errors.each(&block)
      end
    end
  end
end

ActiveModel::Errors.include FatFreeCRM::ActiveModel::Errors
