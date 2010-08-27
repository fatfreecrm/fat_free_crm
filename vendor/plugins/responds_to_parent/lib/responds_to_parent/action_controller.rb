module RespondsToParent
  # Module containing the methods useful for child IFRAME to parent window communication
  module ActionController
    # Executes the response body as JavaScript in the context of the parent window.
    # Use this method of you are posting a form to a hidden IFRAME or if you would like
    # to use IFRAME base RPC.
    def responds_to_parent(&block)
      script_view_context = view_context_class.new(lookup_context, view_assigns, self)
			
			script_generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(script_view_context, &block)
      script = script_generator.to_s

			response.headers['Content-Type'] = 'text/html; charset=UTF-8'
			
			render :text => "<html><body><script type='text/javascript' charset='utf-8'>
        var loc = document.location;
        with(window.parent) { setTimeout(function() { window.eval('#{self.class.helpers.escape_javascript script}'); window.loc && loc.replace('about:blank'); }, 1) }
      </script></body></html>"
    end
    alias respond_to_parent responds_to_parent
  end
end