require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "opportunities", :action => "index").should == "/opportunities"
    end
  
    it "maps #new" do
      route_for(:controller => "opportunities", :action => "new").should == "/opportunities/new"
    end
  
    it "maps #show" do
      route_for(:controller => "opportunities", :action => "show", :id => "1").should == "/opportunities/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "opportunities", :action => "edit", :id => "1").should == "/opportunities/1/edit"
    end
  
    it "maps #create" do
      route_for(:controller => "opportunities", :action => "create").should == { :path => "/opportunities", :method => :post }
    end 

    it "maps #update" do
      route_for(:controller => "opportunities", :action => "update", :id => "1").should == { :path => "/opportunities/1", :method => :put }
    end
  
    it "maps #destroy" do
      route_for(:controller => "opportunities", :action => "destroy", :id => "1").should == { :path => "/opportunities/1", :method => :delete }
    end

    it "maps #search" do
      route_for(:controller => "opportunities", :action => "search", :id => "1").should == "/opportunities/search/1"
    end

    it "maps #auto_complete" do
      route_for(:controller => "opportunities", :action => "auto_complete", :id => "1").should == "/opportunities/auto_complete/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/opportunities").should == {:controller => "opportunities", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/opportunities/new").should == {:controller => "opportunities", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/opportunities").should == {:controller => "opportunities", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/opportunities/1").should == {:controller => "opportunities", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/opportunities/1/edit").should == {:controller => "opportunities", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/opportunities/1").should == {:controller => "opportunities", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/opportunities/1").should == {:controller => "opportunities", :action => "destroy", :id => "1"}
    end

    it "should generate params for #search" do
      params_from(:get, "/opportunities/search/1").should == {:controller => "opportunities", :action => "search", :id => "1"}
    end

    it "should generate params for #auto_complete" do
      params_from(:post, "/opportunities/auto_complete/1").should == {:controller => "opportunities", :action => "auto_complete", :id => "1"}
    end
  end
end
