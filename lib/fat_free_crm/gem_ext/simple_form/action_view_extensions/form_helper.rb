# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
#
# Removes simple_form's css class logic.
module SimpleForm
  module ActionViewExtensions
    module FormHelper
      def simple_form_for(record, options = {}, &block)
        options[:builder] ||= SimpleForm::FormBuilder
        options[:html] ||= {}
        unless options[:html].key?(:novalidate)
          options[:html][:novalidate] = !SimpleForm.browser_validations
        end

        with_simple_form_field_error_proc do
          form_for(record, options, &block)
        end
      end
    end
  end
end
