require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "admin/users", :action => "index").should == "/admin/users"
    end

    it "maps #new" do
      route_for(:controller => "admin/users", :action => "new").should == "/admin/users/new"
    end

    it "maps #show" do
      route_for(:controller => "admin/users", :action => "show", :id => "1").should == "/admin/users/1"
    end

    it "maps #edit" do
      route_for(:controller => "admin/users", :action => "edit", :id => "1").should == "/admin/users/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "admin/users", :action => "create").should == {:path => "/admin/users", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "admin/users", :action => "update", :id => "1").should == {:path =>"/admin/users/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "admin/users", :action => "destroy", :id => "1").should == {:path =>"/admin/users/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/admin/users").should == {:controller => "admin/users", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/admin/users/new").should == {:controller => "admin/users", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/admin/users").should == {:controller => "admin/users", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/admin/users/1").should == {:controller => "admin/users", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/admin/users/1/edit").should == {:controller => "admin/users", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/admin/users/1").should == {:controller => "admin/users", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/admin/users/1").should == {:controller => "admin/users", :action => "destroy", :id => "1"}
    end
  end
end
