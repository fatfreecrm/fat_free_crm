# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

shared_examples "auto complete" do
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

  it "should render application/_auto_complete template" do
    post :auto_complete, :auto_complete_query => @query
    response.should render_template("application/_auto_complete")
  end
end

shared_examples "attach" do
  it "should attach existing asset to the parent asset of different type" do
    xhr :put, :attach, :id => @model.id, :assets => @connected_object.class.name.tableize, :asset_id => @connected_object.id
    @model.send(@connected_object.class.name.tableize).should include(@connected_object)
    assigns[:connected_object].should == @connected_object
    assigns[:attached].should == [ @connected_object ]
    if @model.is_a?(Campaign) && (@connected_object.is_a?(Lead) || @connected_object.is_a?(Opportunity))
      assigns[:campaign].should == @connected_object.reload.campaign
    end
    if @model.is_a?(Account) && @connected_object.respond_to?(:account) # Skip Tasks...
      assigns[:account].should == @connected_object.reload.account
    end
    response.should render_template("entities/attach")
  end

  it "should not attach the asset that is already attached" do
    if @model.is_a?(Campaign) && (@connected_object.is_a?(Lead) || @connected_object.is_a?(Opportunity))
      @connected_object.update_attribute(:campaign_id, @model.id)
    else
      @model.send(@connected_object.class.name.tableize) << @connected_object
    end

    xhr :put, :attach, :id => @model.id, :assets => @connected_object.class.name.tableize, :asset_id => @connected_object.id
    assigns[:attached].should == nil
    response.should render_template("entities/attach")
  end

  it "should display flash warning when the model is no longer available" do
    @model.destroy

    xhr :put, :attach, :id => @model.id, :assets => @connected_object.class.name.tableize, :asset_id => @connected_object.id
    flash[:warning].should_not == nil
    response.body.should == "window.location.reload();"
  end
  it "should display flash warning when the connected_object is no longer available" do
    @connected_object.destroy

    xhr :put, :attach, :id => @model.id, :assets => @connected_object.class.name.tableize, :asset_id => @connected_object.id
    flash[:warning].should_not == nil
    response.body.should == "window.location.reload();"
  end
end

shared_examples "discard" do
  it "should discard the connected_object without deleting it" do
    xhr :post, :discard, :id => @model.id, :connected_object => @connected_object.class.name, :connected_object_id => @connected_object.id
    assigns[:connected_object].should == @connected_object.reload                     # The connected_object should still exist.
    @model.reload.send("#{@connected_object.class.name.tableize}").should == [] # But no longer associated with the model.
    assigns[:account].should == @model if @model.is_a?(Account)
    assigns[:campaign].should == @model if @model.is_a?(Campaign)

    response.should render_template("entities/discard")
  end

  it "should display flash warning when the model is no longer available" do
    @model.destroy

    xhr :post, :discard, :id => @model.id, :connected_object => @connected_object.class.name, :connected_object_id => @connected_object.id
    flash[:warning].should_not == nil
    response.body.should == "window.location.reload();"
  end

  it "should display flash warning when the connected_object is no longer available" do
    @connected_object.destroy

    xhr :post, :discard, :id => @model.id, :connected_object => @connected_object.class.name, :connected_object_id => @connected_object.id
    flash[:warning].should_not == nil
    response.body.should == "window.location.reload();"
  end
end
