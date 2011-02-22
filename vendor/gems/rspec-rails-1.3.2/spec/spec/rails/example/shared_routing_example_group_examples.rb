class CustomRouteSpecController < ActionController::Base; end
class RspecOnRailsSpecsController < ActionController::Base; end

share_as :RoutingExampleGroupSpec do
  describe "using backward compatible route_for()" do
    it "translates GET-only paths to be explicit" do
      self.should_receive(:assert_routing).with(hash_including(:method => :get), anything, {}, anything)
      route_for(:controller => "controller_spec", :action => "some_action").
        should == "/controller_spec/some_action"
    end

    it "uses assert_routing to specify that the :controller and :action are involved" do
      @route = { :controller => "controller_spec", :action => "some_action" }
      self.should_receive(:assert_routing).with(anything, @route, {}, anything)
      route_for(@route).
        should == "/controller_spec/some_action"
    end

    it "passes extra args through to assert_routing" do
      @route = { :controller => "controller_spec", :action => "some_action" }
      self.should_receive(:assert_routing).with(anything, anything, {}, { :a => "1", :b => "2" } )
      route_for(@route).
        should == "/controller_spec/some_action?a=1&b=2"
    end

    it "passes with an existing route" do
      route_for(:controller => "controller_spec", :action => "some_action").
        should == "/controller_spec/some_action"
    end

    it "passes with an existing route with additional parameters" do
      route_for(:controller => "controller_spec", :action => "some_action", :param => '1').
        should == "/controller_spec/some_action?param=1"
    end

    it "recognizes routes with methods besides :get" do
      should_receive(:assert_routing).with(hash_including(:method => :put), anything, {},  anything)

      route_for(:controller => "rspec_on_rails_specs", :action => "update", :id => "37").
        should == {:path => "/rspec_on_rails_specs/37", :method => :put}
    end
    
    describe "failing due to bad path:" do
      it "raises routing error and suggests should_not be_routeable()" do
        lambda {
          route_for(:controller => "rspec_on_rails_specs", :action => "nonexistent", :id => "37") ==
            {:path => "/rspec_on_rails_specs/bad_route/37", :method => :put}
        }.should raise_error( ActionController::RoutingError, /suggest.*should_not be_routable/ )
      end
    end

    describe "failing due to params mismatch:" do
      it "re-raises assertion and suggests should_not be_routeable()" do
        lambda {
          route_for(:controller => "rspec_on_rails_specs", :action => "nonexistent", :id => "37") ==
            {:path => "/rspec_on_rails_specs/37", :method => :put}
        }.should raise_error( ::Test::Unit::AssertionFailedError, /suggest.*should_not be_routable/ )
      end
    end

    describe "failing due to wrong HTTP method" do
      it "raises method error and suggest should_not be_routable()" do
        lambda {
          route_for(:controller => "rspec_on_rails_specs", :action => "update", :id => "37").
            should == {:path => "/rspec_on_rails_specs/37", :method => :post}
        }.should raise_error(ActionController::MethodNotAllowed) { |error| error.should_not =~ /should_not be_routable/ }
      end
    end

    it "generates params for custom routes" do
      # redundant, deprecated
      params_from(:get, '/custom_route').
        should == {:controller => "custom_route_spec", :action => "custom_route"}
    end

    it "generates params for existing routes" do
      # redundant, deprecated
      params_from(:get, '/controller_spec/some_action').
        should == {:controller => "controller_spec", :action => "some_action"}
    end

    it "generates params for existing routes with a query parameters" do
      # redundant, deprecated
      params_from(:get, '/controller_spec/some_action?param=1').
        should == {:controller => "controller_spec", :action => "some_action", :param => '1'}
    end

    it "generates params for existing routes with multiple query parameters" do
      # redundant, deprecated
      params_from(:get, '/controller_spec/some_action?param1=1&param2=2').
        should == {:controller => "controller_spec", :action => "some_action", :param1 => '1', :param2 => '2' }
    end
  end
end

share_as :BeRoutableExampleGroupSpec do
  describe "using should_not be_routable()" do
    it "passes for a bad route" do
      { :put => "/rspec_on_rails_specs/bad_route/37" }.
        should_not be_routable
    end
    it "passes for a bad route having an arg" do
      { :put => "/rspec_on_rails_specs/bad_route/37?some_arg=1" }.
        should_not be_routable
    end
    describe "when assert_recognizes throws exceptions:" do
      [ ActionController::RoutingError, ActionController::MethodNotAllowed ].each do |e|
        it "passes on #{e}" do
          self.stub!( :assert_recognizes ).and_return { raise e, "stubbed exception" }
          { :get => "/rspec_on_rails_spec/bad_route/37" }.should_not be_routable
        end
        it "should be_routable on usual Test::Unit::AssertionFailedError" do
          # <{}> is predictable because of the way we call assert_recognizes during be_routable().
          self.stub!( :assert_recognizes ).and_return { raise ::Test::Unit::AssertionFailedError, "<{a}> did not match <{}>" }
          { :get => "/rspec_on_rails_spec/arguably_bad_route" }.should be_routable
        end
        it "should re-raise on unusual Test::Unit::AssertionFailedError" do
          self.stub!( :assert_recognizes ).and_return { raise ::Test::Unit::AssertionFailedError, "some other message" }
          expect { { :get => "/rspec_on_rails_spec/weird_case_route/" }.should be_routable }.
            to raise_error
        end
      end
    end
    it "test should be_routable" do
      { :get => "/custom_route" }.
        should be_routable
    end

    it "recommends route_to() on failure with should()" do
      lambda {
        { :get => "/nonexisting_route" }.
          should be_routable
      }.should raise_error( /route_to\(/)
    end

    it "shows actual route that was generated on failure with should_not()" do
      begin
        { :get => "/custom_route" }.should_not be_routable
      rescue Exception => e
      ensure
        # Different versions of ruby order these differently
        e.message.should =~ /"action"=>"custom_route"/
        e.message.should =~ /"controller"=>"custom_route_spec"/
      end
    end

    it "works with routeable (alternate spelling)" do
      { :put => "/nonexisting_route" }.
        should_not be_routeable
    end
  end
end

share_as :RouteToExampleGroupSpec do
  describe "using should[_not] route_to()" do
    it "supports existing routes" do
      { :get => "/controller_spec/some_action" }.
        should route_to( :controller => "controller_spec", :action => "some_action" )
    end

    it "translates GET-only paths to be explicit, when matching against a string (for parity with route_for().should == '/path')" do
      self.should_receive(:assert_routing).with(hash_including(:method => :get), anything, {}, anything)
      "/controller_spec/some_action".
        should route_to({})
    end

    it "asserts, using assert_routing, that the :controller and :action are involved" do
      @route = { :controller => "controller_spec", :action => "some_action" }
      self.should_receive(:assert_routing).with(anything, @route, {}, anything)
      "/controller_spec/some_action".
        should route_to(@route)
    end
    
    it "sends extra args through" do
      @route = { :controller => "controller_spec", :action => "some_action" }
      self.should_receive(:assert_routing).with(anything, anything, {}, { :a => "1", :b => "2" } )
      "/controller_spec/some_action?a=1&b=2".
        should route_to( @route )
    end

    it "supports routes with additional parameters" do
      { :get => "/controller_spec/some_action?param=1" }.
        should route_to( :controller => "controller_spec", :action => "some_action", :param => '1' )
    end

    it "recognizes routes with methods besides :get" do
      self.should_receive(:assert_routing).with(hash_including(:method => :put), anything, {}, anything)
      { :put => "/rspec_on_rails_specs/37" }.
        should route_to(:controller => "rspec_on_rails_specs", :action => "update", :id => "37")
    end

    it "allows only one key/value in the path - :method => path" do
      lambda {
        { :a => "b" ,:c => "d" }.
          should route_to("anything")
      }.should raise_error( ArgumentError, /usage/ )
    end

    describe "failing due to bad path" do
      it "raises routing error, and suggests should_not be_routeable()" do
        lambda {
          { :put => "/rspec_on_rails_specs/nonexistent/37" }.
            should route_to(:controller => "rspec_on_rails_specs", :action => "nonexistent", :id => "37")
        }.should raise_error( ActionController::RoutingError, /suggest.*nonexistent.*should_not be_routable/ )
      end
    end
    
    describe "failing due to params mismatch" do
      it "raises assertion, and suggests should_not be_routeable()" do
        lambda {
          { :put => "/rspec_on_rails_specs/37" }.
            should route_to(:controller => "rspec_on_rails_specs", :action => "nonexistent", :id => "37")
        }.should raise_error( ::Test::Unit::AssertionFailedError, /suggest.*rspec_on_rails_specs\/37.*should_not be_routable/ )
      end
    end
    
    describe "passing when expected failure" do
      it "suggests should_not be_routable()" do
        self.stub!(:assert_routing).and_return true
        lambda {
          { :put => "/rspec_on_rails_specs/37" }.
            should_not route_to(:controller => "rspec_on_rails_specs", :action => "update", :id => "37")
        }.should raise_error( /expected a routing error.*be_routable/im )
      end
    end

    describe "failing due to wrong HTTP method" do
      it "raises method error and suggests should_not be_routable()" do
        self.stub!(:assert_routing) { raise ActionController::MethodNotAllowed }
        lambda {
          { :post => "/rspec_on_rails_specs/37" }.
            should route_to(:controller => "rspec_on_rails_specs", :action => "update", :id => "37" )
        }.should raise_error(ActionController::MethodNotAllowed, /rspec_on_rails_specs\/37.*should_not be_routable/ )
      end
    end
  end
end
