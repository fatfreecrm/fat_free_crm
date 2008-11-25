require 'action_controller/cookies'

module Spec
  module Rails
    module Example
      class CookiesProxy
        def initialize(example)
          @example = example
        end
      
        def[]=(name, value)
          @example.request.cookies[name.to_s] = CGI::Cookie.new(name.to_s, value)
        end
        
        def [](name)
          @example.response.cookies[name.to_s]
        end
      
        def delete(name)
          @example.response.cookies.delete(name.to_s)
        end
      end
    end
  end
end
