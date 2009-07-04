require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "users", :action => "index").should == "/users"
    end
  
    it "maps #new" do
      route_for(:controller => "users", :action => "new").should == "/users/new"
    end
  
    it "maps #show" do
      route_for(:controller => "users", :action => "show", :id => "1").should == "/users/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "users", :action => "edit", :id => "1").should == "/users/1/edit"
    end
  
    it "maps #create" do
      route_for(:controller => "users", :action => "create").should == { :path => "/users", :method => :post }
    end 

    it "maps #update" do
      route_for(:controller => "users", :action => "update", :id => "1").should == { :path => "/users/1", :method => :put }
    end
  
    it "maps #destroy" do
      route_for(:controller => "users", :action => "destroy", :id => "1").should == { :path => "/users/1", :method => :delete }
    end

    it "maps #avatar" do
      route_for(:controller => "users", :action => "avatar", :id => "1").should == "/users/1/avatar"
    end

    it "maps #upload_avatar" do
      route_for(:controller => "users", :action => "upload_avatar", :id => "1").should == { :path => "/users/1/upload_avatar", :method => :put }
    end

    it "maps #password" do
      route_for(:controller => "users", :action => "password", :id => "1").should == "/users/1/password"
    end

    it "maps #change_password" do
      route_for(:controller => "users", :action => "change_password", :id => "1").should == { :path => "/users/1/change_password", :method => :put }
    end

  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/users").should == {:controller => "users", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/users/new").should == {:controller => "users", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/users").should == {:controller => "users", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/users/1").should == {:controller => "users", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/users/1/edit").should == {:controller => "users", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/users/1").should == {:controller => "users", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/users/1").should == {:controller => "users", :action => "destroy", :id => "1"}
    end

    it "should generate params for #avatar" do
      params_from(:get, "/users/1/avatar").should == {:controller => "users", :action => "avatar", :id => "1"}
    end

    it "should generate params for #upload_avatar" do
      params_from(:put, "/users/upload_avatar/1").should == {:controller => "users", :action => "upload_avatar", :id => "1"}
    end

    it "should generate params for #password" do
      params_from(:put, "/users/password/1").should == {:controller => "users", :action => "password", :id => "1"}
    end

    it "should generate params for #change_password" do
      params_from(:put, "/users/change_password/1").should == {:controller => "users", :action => "change_password", :id => "1"}
    end
  end
end
