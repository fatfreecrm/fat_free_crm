require 'rack/utils'

module Spec
  module Rails
    module Matchers
      USAGE = ArgumentError.new( 'usage: { :method => "path" }.should route_to( :controller => "controller", :action => "action", [ args ] )' )

      class PathDecomposer
        def self.decompose_path(path)
          method, path = if Hash === path
                           raise USAGE if path.keys.size > 1
                           path.entries.first
                         else
                           [:get, path]
                         end
          path, querystring = path.split('?')
          return method, path, querystring
        end
      end

      class RouteTo #:nodoc:
        def initialize(expected, example)
          @route, @example = expected,example
        end

        def matches?(path)
          begin
            @actual = path
            method, path, querystring = PathDecomposer.decompose_path(path)
            params = querystring.blank? ? {} : Rack::Utils.parse_query(querystring).symbolize_keys!
            @example.assert_routing({ :method => method, :path => path }, @route, {}, params)
            true
          rescue ActionController::RoutingError, ::Test::Unit::AssertionFailedError, ActionController::MethodNotAllowed => e
            raise e.class, "#{e}\nIf you're expecting this failure, we suggest { :#{method} => \"#{path}\" }.should_not be_routable"
          rescue Exception => e
            raise e.class, "#{e}\n#{e.backtrace.join( "\n" )}"
          end
        end

        def does_not_match(path)
          raise ArgumentError, "Don't test a negative route like this."
        end

        def failure_message_for_should
          "Expected #{@expected.inspect} to route to #{@actual.inspect}, but it didn't.\n"+
          "In this case, we expected you to get an exception.  So this message probably means something weird happened."
        end

        def failure_message_for_should_not
          "Expected a routing error, but the route passed instead.  \nNote, when expecting routes to fail, you should use 'should_not be_routable' instead."
        end

        def description
          "route to #{@expected.inspect}"
        end

        private
          attr_reader :expected
          attr_reader :actual

      end

      # :call-seq:
      #   "path".should route_to(expected)  # assumes GET
      #   { :get => "path" }.should route_to(expected)
      #   { :put => "path" }.should route_to(expected)
      #
      # Uses ActionController::Routing::Routes to verify that
      # the path-and-method routes to a given set of options.
      # Also verifies route-generation, so that the expected options
      # do generate a pathname consisten with the indicated path/method.
      #
      # For negative tests, only the route recognition failure can be
      # tested; since route generation via path_to() will always generate
      # a path as requested.  Use .should_not be_routable() in this case.
      #
      # == Examples
      # { :get => '/registrations/1/edit' }.
      #   should route_to(:controller => 'registrations', :action => 'edit', :id => '1')
      # { :put => "/registrations/1" }.should
      #   route_to(:controller => 'registrations', :action => 'update', :id => 1)
      # { :post => "/registrations/" }.should
      #   route_to(:controller => 'registrations', :action => 'create')

      def route_to(expected)
        RouteTo.new(expected, self)
      end

      class BeRoutable
        def initialize(example)
          @example = example
        end

        def matches?(path)
          begin
            @actual = path
            method, path = PathDecomposer.decompose_path(path)
            @example.assert_recognizes({}, { :method => method, :path => path }, {} )
            true
          rescue ActionController::RoutingError, ActionController::MethodNotAllowed
            false
          rescue ::Test::Unit::AssertionFailedError => e
            # the second thingy will always be "<{}>" becaues of the way we called assert_recognizes({}...) above.
            e.to_s =~ /<(.*)> did not match <\{\}>/ and @actual_place = $1 or raise
            true
          end
        end
        def failure_message_for_should
          "Expected '#{@actual.keys.first.to_s.upcase} #{@actual.values.first}' to be routable, but it wasn't.\n"+
          "To really test routability, we recommend #{@actual.inspect}.\n"+
          "  should route_to( :action => 'action', :controller => 'controller' )\n\n"+

          "That way, you'll verify where your route goes to.  Plus, we'll verify\n"+
          "the generation of the expected path from the action/controller, as in\n"+
          "the url_for() helper."
        end

        def failure_message_for_should_not
          "Expected '#{@actual.keys.first.to_s.upcase} #{@actual.values.first}' to fail, but it routed to #{@actual_place} instead"
        end

      end
      # :call-seq:
      #   { "path" }.should_not be_routable # assumes GET
      #   { :get => "path" }.should_not be_routable
      #   { :put => "path" }.should_not be_routable
      #
      # Uses ActionController::Routing::Routes to verify that
      # the path-and-method cannot be routed to a controller.
      # Since url_for() will always generate a path, even if that
      # path is not routable, the negative test only needs to be
      # performed on the route recognition.
      #
      # Don't use this matcher for testing expected routability -
      # use .should route_to( :controller => "controller", :action => "action" ) instead
      #
      # == Examples
      # { :get => '/registrations/1/attendees/3/edit' }.should_not be_routable
      # { :get => '/attendees/3/edit' }.should route_to( ...<controller/action>... )

      def be_routable
        BeRoutable.new(self)
      end

      alias_method :be_routeable, :be_routable
    end
  end
end

