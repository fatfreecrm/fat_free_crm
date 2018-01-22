# frozen_string_literal: true

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
    get :auto_complete, params: { term: @query }
    expect(assigns[:query]).to eq(@query)
    expect(assigns[:auto_complete]).to eq(@auto_complete_matches) # Each controller must define it.
  end

  it "should save current autocomplete controller in a session" do
    get :auto_complete, params: { term: @query }

    # We don't save Admin/Users autocomplete controller in a session since Users are not
    # exposed through the Jumpbox.
    unless controller.class.to_s.starts_with?("Admin::")
      expect(session[:auto_complete]).to eq(@controller.controller_name.to_sym)
    end
  end

  it "should render application/_auto_complete template" do
    post :auto_complete, params: { term: @query }
    expect(response).to render_template("application/_auto_complete")
  end
end

shared_examples "attach" do
  it "should attach existing asset to the parent asset of different type" do
    put :attach, params: { id: @model.id, assets: @attachment.class.name.tableize, asset_id: @attachment.id }, xhr: true
    expect(@model.send(@attachment.class.name.tableize)).to include(@attachment)
    expect(assigns[:attachment]).to eq(@attachment)
    expect(assigns[:attached]).to eq([@attachment])
    if @model.is_a?(Campaign) && (@attachment.is_a?(Lead) || @attachment.is_a?(Opportunity))
      expect(assigns[:campaign]).to eq(@attachment.reload.campaign)
    end
    if @model.is_a?(Account) && @attachment.respond_to?(:account) # Skip Tasks...
      expect(assigns[:account]).to eq(@attachment.reload.account)
    end
    expect(response).to render_template("entities/attach")
  end

  it "should not attach the asset that is already attached" do
    if @model.is_a?(Campaign) && (@attachment.is_a?(Lead) || @attachment.is_a?(Opportunity))
      @attachment.update_attribute(:campaign_id, @model.id)
    else
      @model.send(@attachment.class.name.tableize) << @attachment
    end

    put :attach, params: { id: @model.id, assets: @attachment.class.name.tableize, asset_id: @attachment.id }, xhr: true
    expect(assigns[:attached]).to eq(nil)
    expect(response).to render_template("entities/attach")
  end

  it "should display flash warning when the model is no longer available" do
    @model.destroy

    put :attach, params: { id: @model.id, assets: @attachment.class.name.tableize, asset_id: @attachment.id }, xhr: true
    expect(flash[:warning]).not_to eq(nil)
    expect(response.body).to eq("window.location.reload();")
  end
  it "should display flash warning when the attachment is no longer available" do
    @attachment.destroy

    put :attach, params: { id: @model.id, assets: @attachment.class.name.tableize, asset_id: @attachment.id }, xhr: true
    expect(flash[:warning]).not_to eq(nil)
    expect(response.body).to eq("window.location.reload();")
  end
end

shared_examples "discard" do
  it "should discard the attachment without deleting it" do
    post :discard, params: { id: @model.id, attachment: @attachment.class.name, attachment_id: @attachment.id }, xhr: true
    expect(assigns[:attachment]).to eq(@attachment.reload)                     # The attachment should still exist.
    expect(@model.reload.send(@attachment.class.name.tableize.to_s)).to eq([]) # But no longer associated with the model.
    expect(assigns[:account]).to eq(@model) if @model.is_a?(Account)
    expect(assigns[:campaign]).to eq(@model) if @model.is_a?(Campaign)

    expect(response).to render_template("entities/discard")
  end

  it "should display flash warning when the model is no longer available" do
    @model.destroy

    post :discard, params: { id: @model.id, attachment: @attachment.class.name, attachment_id: @attachment.id }, xhr: true
    expect(flash[:warning]).not_to eq(nil)
    expect(response.body).to eq("window.location.reload();")
  end

  it "should display flash warning when the attachment is no longer available" do
    @attachment.destroy

    post :discard, params: { id: @model.id, attachment: @attachment.class.name, attachment_id: @attachment.id }, xhr: true
    expect(flash[:warning]).not_to eq(nil)
    expect(response.body).to eq("window.location.reload();")
  end
end
