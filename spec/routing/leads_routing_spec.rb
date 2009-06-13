require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "leads", :action => "index").should == "/leads"
    end
  
    it "maps #new" do
      route_for(:controller => "leads", :action => "new").should == "/leads/new"
    end
  
    it "maps #show" do
      route_for(:controller => "leads", :action => "show", :id => "1").should == "/leads/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "leads", :action => "edit", :id => "1").should == "/leads/1/edit"
    end
  
    it "maps #create" do
      route_for(:controller => "leads", :action => "create").should == { :path => "/leads", :method => :post }
    end 

    it "maps #update" do
      route_for(:controller => "leads", :action => "update", :id => "1").should == { :path => "/leads/1", :method => :put }
    end
  
    it "maps #destroy" do
      route_for(:controller => "leads", :action => "destroy", :id => "1").should == { :path => "/leads/1", :method => :delete }
    end

    it "maps #search" do
      route_for(:controller => "leads", :action => "search", :id => "1").should == "/leads/search/1"
    end

    it "maps #convert" do
      route_for(:controller => "leads", :action => "convert", :id => "1").should == "/leads/1/convert"
    end

    it "maps #promote" do
      route_for(:controller => "leads", :action => "promote", :id => "1").should == { :path => "/leads/1/promote", :method => :put }
    end

    it "maps #reject" do
      route_for(:controller => "leads", :action => "reject", :id => "1").should == { :path => "/leads/1/reject", :method => :put }
    end

    it "maps #auto_complete" do
      route_for(:controller => "leads", :action => "auto_complete", :id => "1").should == "/leads/auto_complete/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/leads").should == {:controller => "leads", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/leads/new").should == {:controller => "leads", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/leads").should == {:controller => "leads", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/leads/1").should == {:controller => "leads", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/leads/1/edit").should == {:controller => "leads", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/leads/1").should == {:controller => "leads", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/leads/1").should == {:controller => "leads", :action => "destroy", :id => "1"}
    end

    it "should generate params for #search" do
      params_from(:get, "/leads/search/1").should == {:controller => "leads", :action => "search", :id => "1"}
    end

    it "should generate params for #convert" do
      params_from(:get, "/leads/1/convert").should == {:controller => "leads", :action => "convert", :id => "1"}
    end

    it "should generate params for #promote" do
      params_from(:put, "/leads/1/promote").should == {:controller => "leads", :action => "promote", :id => "1"}
    end

    it "should generate params for #reject" do
      params_from(:put, "/leads/1/reject").should == {:controller => "leads", :action => "reject", :id => "1"}
    end

    it "should generate params for #auto_complete" do
      params_from(:post, "/leads/auto_complete/1").should == {:controller => "leads", :action => "auto_complete", :id => "1"}
    end
  end
end
