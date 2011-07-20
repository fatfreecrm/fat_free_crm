module SharedControllerSpecs

  shared_examples_for "auto complete" do
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

      # We don't save Admin/Users autocomplete controller in a session since Users are not
      # exposed through the Jumpbox.
      unless controller.class.to_s.starts_with?("Admin::")
        session[:auto_complete].should == @controller.controller_name.to_sym
      end
    end

    it "should render common/auto_complete template" do
      post :auto_complete, :auto_complete_query => @query
      response.should render_template("common/auto_complete")
    end
  end

  shared_examples_for "attach" do
    it "should attach existing asset to the parent asset of different type" do
      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      @model.send(@attachment.class.name.tableize).should include(@attachment)
      assigns[:attachment].should == @attachment
      assigns[:attached].should == [ @attachment ]
      if @model.is_a?(Campaign) && (@attachment.is_a?(Lead) || @attachment.is_a?(Opportunity))
        assigns[:campaign].should == @attachment.reload.campaign
      end
      if @model.is_a?(Account) && @attachment.respond_to?(:account) # Skip Tasks...
        assigns[:account].should == @attachment.reload.account
      end
      response.should render_template("common/attach")
    end

    it "should not attach the asset that is already attached" do
      if @model.is_a?(Campaign) && (@attachment.is_a?(Lead) || @attachment.is_a?(Opportunity))
        @attachment.update_attribute(:campaign_id, @model.id)
      else
        @model.send(@attachment.class.name.tableize) << @attachment
      end

      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      assigns[:attached].should == nil
      response.should render_template("common/attach")
    end

    it "should display flash warning when the model is no longer available" do
      @model.destroy

      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
    it "should display flash warning when the attachment is no longer available" do
      @attachment.destroy

      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end

  shared_examples_for "discard" do
    it "should discard the attachment without deleting it" do
      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      assigns[:attachment].should == @attachment.reload                     # The attachment should still exist.
      @model.reload.send("#{@attachment.class.name.tableize}").should == [] # But no longer associated with the model.
      assigns[:account].should == @model if @model.is_a?(Account)
      assigns[:campaign].should == @model if @model.is_a?(Campaign)

      response.should render_template("common/discard")
    end

    it "should display flash warning when the model is no longer available" do
      @model.destroy

      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end

    it "should display flash warning when the attachment is no longer available" do
      @attachment.destroy

      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end

end
