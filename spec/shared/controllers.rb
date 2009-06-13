module SharedControllerSpecs

  describe "auto complete", :shared => true do
    before(:each) do
      @query = "Hello"
    end

    it "should do the search and find records that match autocomplete query" do
      post :auto_complete, :auto_complete_query => @query
      assigns[:query].should == @query
      assigns[:auto_complete].should == @auto_complete_matches # Each controller must define it.
    end
    
    it "should save current autocomplete controller in a session" do
      post :auto_complete, :auto_complete_query => @query
      session[:auto_complete].should == @controller.controller_name.to_sym
    end

    it "should render common/auto_complete template" do
      post :auto_complete, :auto_complete_query => @query
      response.should render_template("common/auto_complete")
    end
  end

end
