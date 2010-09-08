module RespondsToParent
  # Module containing the methods useful for child IFRAME to parent window communication
  module ActionController
    # Executes the response body as JavaScript in the context of the parent window.
    # Use this method of you are posting a form to a hidden IFRAME or if you would like
    # to use IFRAME base RPC.
    def responds_to_parent(&block)
      yield
    
      if performed?
        # Either pull out a redirect or the request body
        script =  if location = erase_redirect_results
                    "document.location.href = '#{self.class.helpers.escape_javascript location.to_s}'"
                  else
                    response.body || ''
                  end

        # Clear out the previous render to prevent double render
        erase_results

        # We're returning HTML instead of JS or XML now
        response.headers['Content-Type'] = 'text/html; charset=UTF-8'

        # Eval in parent scope and replace document location of this frame 
        # so back button doesn't replay action on targeted forms
        # loc = document.location to be set after parent is updated for IE
        # with(window.parent) - pull in variables from parent window
        # window.eval - legal eval for Opera
        render :text => "<html><body><script type='text/javascript' charset='utf-8'>
          var loc = document.location;
          with(window.parent) { window.eval('#{self.class.helpers.escape_javascript script}'); window.loc && loc.replace('about:blank'); }
        </script></body></html>"
      end
    end
    alias respond_to_parent responds_to_parent
  end
end