require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "fat_free_crm/view_factory"

describe FatFreeCRM::ViewFactory do

  before(:each) do
    FatFreeCRM::ViewFactory.class_variable_set('@@views', [])
  end
  
  describe "initialization" do
  
    before(:each) do
      @view_params = {:name => 'brief', :title => 'Brief View', :icon => 'brief.png', :controllers => ['contacts'], :actions => ['show', 'index']}
    end
    
    it "should initialize with required parameters" do
      view = FatFreeCRM::ViewFactory.new @view_params
      view.name.should == 'brief'
      view.title.should == 'Brief View'
      view.controllers.should include('contacts')
      view.actions.should include('show')
      view.actions.should include('index')
    end
    
    it "should register view with ViewFactory" do
      FatFreeCRM::ViewFactory.class_variable_get('@@views').size.should == 0
      FatFreeCRM::ViewFactory.new @view_params
      FatFreeCRM::ViewFactory.class_variable_get('@@views').size.should == 1
    end
    
    it "should not register the same view twice" do
      FatFreeCRM::ViewFactory.new @view_params
      FatFreeCRM::ViewFactory.new @view_params
      views = FatFreeCRM::ViewFactory.class_variable_get('@@views')
      views.size.should == 1
    end
    
  end

  describe "views_for" do
    
    before(:each) do
      @v1 = FatFreeCRM::ViewFactory.new :name => 'brief', :title => 'Brief View', :controllers => ['contacts'], :actions => ['show', 'index']
      @v2 = FatFreeCRM::ViewFactory.new :name => 'long', :title => 'Long View', :controllers => ['contacts'], :actions => ['show']
      @v3 = FatFreeCRM::ViewFactory.new :name => 'full', :title => 'Full View', :controllers => ['accounts'], :actions => ['show']
    end
    
    it "should return 'brief' view for ContactsController#index" do
      FatFreeCRM::ViewFactory.views_for(:controller => 'contacts', :action => 'index').should == [@v1]
    end
    
    it "should return 'brief' and 'long' view for ContactsController#show" do
      views = FatFreeCRM::ViewFactory.views_for(:controller => 'contacts', :action => 'show')
      views.should include(@v1)
      views.should include(@v2)
    end
    
    it "should return 'full' view for AccountsController#show" do
      FatFreeCRM::ViewFactory.views_for(:controller => 'accounts', :action => 'show').should == [@v3]
    end
    
    it "should return no views for TasksController#show" do
      FatFreeCRM::ViewFactory.views_for(:controller => 'tasks', :action => 'show').should == []
    end
    
  end
  
end
