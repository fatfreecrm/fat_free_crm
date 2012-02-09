#  Copyright (c) 2006 Sean Treadway
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Module containing the methods useful for child IFRAME to parent window communication
module RespondsToParent

  # Executes the response body as JavaScript in the context of the parent window.
  # Use this method of you are posting a form to a hidden IFRAME or if you would like
  # to use IFRAME base RPC.
  def responds_to_parent(&block)
    yield

    if performed?
      # We're returning HTML instead of JS or XML now
      response.headers['Content-Type'] = 'text/html; charset=UTF-8'

      # Either pull out a redirect or the request body
      script =  if response.headers['Location']
                  #TODO: erase_redirect_results is missing in rails 3.0 has to be implemented
                  #erase redirect
                  "document.location.href = #{location.to_s.inspect}"
                else
                  response.body
                end

      # Escape quotes, linebreaks and slashes, maintaining previously escaped slashes
      # Suggestions for improvement?
      script = (script || '').
        gsub('\\', '\\\\\\').
        gsub(/\r\n|\r|\n/, '\\n').
        gsub(/['"]/, '\\\\\&').
        gsub('</script>','</scr"+"ipt>')

      # Clear out the previous render to prevent double render
      response.request.env['action_controller.instance'].instance_variable_set(:@_response_body, nil)

      # Eval in parent scope and replace document location of this frame
      # so back button doesn't replay action on targeted forms
      # loc = document.location to be set after parent is updated for IE
      # with(window.parent) - pull in variables from parent window
      # setTimeout - scope the execution in the windows parent for safari
      # window.eval - legal eval for Opera
      render :text => "<html><body><script type='text/javascript' charset='utf-8'>
        var loc = document.location;
        with(window.parent) { setTimeout(function() { window.eval('#{script}'); if (typeof(loc) !== 'undefined') loc.replace('about:blank'); }, 1) };
        </script></body></html>".html_safe
    end
  end
  alias respond_to_parent responds_to_parent
end

