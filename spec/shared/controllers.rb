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

  describe "add_tag", :shared => true do
    before(:each) do
      @class_name = @tagable.class.name.downcase
    end

    describe "HTML request" do
      it "adds the tags to the current tag list" do
        put :add_tag, :id => @tagable.id, :tag => {:name => "go, apple"}
        assigns(@class_name.to_sym).tag_list.should == %w(moo foo bar go apple)
      end

      it "should redirect to the lead show page" do
        tagable_path = send(:"#{@class_name}_path", @tagable)
        put :add_tag, :id => @tagable.id, :tag => {:name => "moo"}
        response.should redirect_to(tagable_path)
      end
    end
  end

  describe "delete_tag", :shared => true do
    before(:each) do
      @class_name = @tagable.class.name.downcase
    end

    describe "HTML request" do
      it "deleting a tag" do
        put :delete_tag, :id => @tagable.id, :tag => "moo"
        assigns(@class_name.to_sym).tag_list.should == %w(foo bar)
      end

      it "should redirect to the lead show page" do
        class_name = @tagable.class.name.downcase
        tagable_path = send(:"#{@class_name}_path", @tagable)

        put :delete_tag, :id => @tagable.id, :tag_list => "moo"
        response.should redirect_to(tagable_path)
      end
    end
  end

  describe "attach", :shared => true do
    it "should attach existing asset to the parent asset of different type" do
      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      @model.send(@attachment.class.name.tableize).should include(@attachment)
      assigns[:attachment].should == @attachment
      assigns[:attached].should == [ @attachment ]
      if @model.is_a?(Campaign) && (@attachment.is_a?(Lead) || @attachment.is_a?(Opportunity))
        assigns[:campaign].should == @attachment.reload.campaign
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

  describe "discard", :shared => true do
    it "should discard the attachment without deleting it" do
      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      assigns[:attachment].should == @attachment.reload               # The attachment should still exist.
      @model.send("#{@attachment.class.name.tableize}").should == []  # But no longer associated with the model.
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
