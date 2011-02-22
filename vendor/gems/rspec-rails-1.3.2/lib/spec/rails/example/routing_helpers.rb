require 'rack/utils'

module Spec
  module Rails
    module Example
      module RoutingHelpers
        
        class RouteFor
          def initialize(example, options)
            @example, @options = example, options
          end

          def ==(expected)
            if Hash === expected
              path, querystring = expected[:path].split('?')
              path_string = path
              path = expected.merge(:path => path)
            else
              path, querystring = expected.split('?')
              path_string = path
              path = { :path => path, :method => :get }
            end
            params = querystring.blank? ? {} : Rack::Utils.parse_query(querystring).symbolize_keys!
            begin
              @example.assert_routing(path, @options, {}, params)
              true
            rescue ActionController::RoutingError, ::Test::Unit::AssertionFailedError => e
              raise e.class, "#{e}\nIf you're expecting this failure, we suggest {:#{path[:method]}=>\"#{path[:path]}\"}.should_not be_routable"
            end
          end
        end
        # Uses ActionController::Routing::Routes to generate
        # the correct route for a given set of options.
        # == Examples
        #   route_for(:controller => 'registrations', :action => 'edit', :id => '1')
        #     => '/registrations/1/edit'
        #   route_for(:controller => 'registrations', :action => 'create')
        #     => {:path => "/registrations", :method => :post}
        def route_for(options)
          RouteFor.new(self, options)
        end

        # Uses ActionController::Routing::Routes to parse
        # an incoming path so the parameters it generates can be checked
        #
        # Note that this method is obsoleted by the route_to matcher.
        # == Example
        #   params_from(:get, '/registrations/1/edit')
        #     => :controller => 'registrations', :action => 'edit', :id => '1'
        def params_from(method, path)
          ensure_that_routes_are_loaded
          path, querystring = path.split('?')
          params = ActionController::Routing::Routes.recognize_path(path, :method => method)
          querystring.blank? ? params : params.merge(Rack::Utils.parse_query(querystring).symbolize_keys!)
        end

      private

        def ensure_that_routes_are_loaded
          ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?
        end

      end
    end
  end
end
