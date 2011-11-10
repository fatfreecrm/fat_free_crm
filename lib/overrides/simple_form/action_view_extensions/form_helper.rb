#
# Changes the default css class for generated forms
# from '<asset>' to 'edit_<asset>' or 'new_<asset>'
# (using params[:action])
module SimpleForm
  module ActionViewExtensions
    module FormHelper
      def css_class_with_action(record, html_options)
        css_class = css_class_without_action(record, html_options)
        # Return defined class, or prepend controller action.
        html_options.key?(:class) ? css_class : [params[:action], css_class].join('_')
      end
      alias_method_chain :css_class, :action
    end
  end
end
