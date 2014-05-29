# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe Admin::UsersController do

  before(:each) do
    login_admin
    set_current_tab(:users)
  end

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  describe "GET index" do
    it "assigns all users as @users and renders [index] template" do
      @users = [ current_user, create(:user) ]
      get :index
      assigns[:users].first.should == @users.last # get_users() sorts by id DESC
      assigns[:users].last.should == @users.first
      response.should render_template("admin/users/index")
    end

    it "performs lookup using query string" do
      @amy = create(:user, username: "amy_anderson")
      @bob = create(:user, username: "bob_builder")

      get :index, query: "amy_anderson"
      assigns[:users].should == [ @amy ]
      assigns[:current_query].should == "amy_anderson"
      session[:users_current_query].should == "amy_anderson"
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  #----------------------------------------------------------------------------
  describe "GET show" do
    it "assigns the requested user as @user and renders [show] template" do
      @user = create(:user)

      get :show, id: @user.id
      assigns[:user].should == @user
      response.should render_template("admin/users/show")
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "GET new" do
    it "assigns a new user as @user and renders [new] template" do
      xhr :get, :new
      expect(assigns[:user]).to be_new_record
      response.should render_template("admin/users/new")
    end
  end

  # GET /admin/users/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  describe "GET edit" do
    it "assigns the requested user as @user and renders [edit] template" do
      @user = create(:user)

      xhr :get, :edit, id: @user.id
      assigns[:user].should == @user
      assigns[:previous].should == nil
      response.should render_template("admin/users/edit")
    end

    it "assigns the previous user as @previous when necessary" do
      @user = create(:user)
      @previous = create(:user)

      xhr :get, :edit, id: @user.id, previous: @previous.id
      assigns[:previous].should == @previous
    end

    it "reloads current page with the flash message if user got deleted" do
      @user = create(:user)
      @user.destroy

      xhr :get, :edit, id: @user.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end

    it "notifies the view if previous user got deleted" do
      @user = create(:user)
      @previous = create(:user)
      @previous.destroy

      xhr :get, :edit, id: @user.id, previous: @previous.id
      flash[:warning].should == nil # no warning, just silently remove the div
      assigns[:previous].should == @previous.id
      response.should render_template("admin/users/edit")
    end
  end

  # POST /admin/users
  # POST /admin/users.xml                                                  AJAX
  #----------------------------------------------------------------------------
  describe "POST create" do

    describe "with valid params" do
      before(:each) do
        @username = "none"
        @email = @username + "@example.com"
        @password = "secret"
      end

      it "assigns a newly created user as @user and renders [create] template" do
        @user = build(:user, username: @username, email: @email)
        User.stub(:new).and_return(@user)

        xhr :post, :create, user: { username: @username, email: @email, password: @password, password_confirmation: @password }
        assigns[:user].should == @user
        response.should render_template("admin/users/create")
      end

      it "creates admin user when requested so" do
        xhr :post, :create, user: { username: @username, email: @email, admin: "1", password: @password, password_confirmation: @password }
        assigns[:user].admin.should == true
        response.should render_template("admin/users/create")
      end

      it "doesn't create admin user unless requested so" do
        xhr :post, :create, user: { username: @username, email: @email, admin: "0", password: @password, password_confirmation: @password }
        assigns[:user].admin.should == false
        response.should render_template("admin/users/create")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user and re-renders [create] template" do
        @user = build(:user, username: "", email: "")
        User.stub(:new).and_return(@user)

        xhr :post, :create, user: {}
        assigns[:user].should == @user
        response.should render_template("admin/users/create")
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested user, assigns it to @user, and renders [update] template" do
        @user = create(:user, username: "flip", email: "flip@example.com")

        xhr :put, :update, id: @user.id, user: { username: "flop", email: "flop@example.com" }
        assigns[:user].should == @user.reload
        assigns[:user].username.should == "flop"
        response.should render_template("admin/users/update")
      end

      it "reloads current page is the user got deleted" do
        @user = create(:user)
        @user.destroy

        xhr :put, :update, id: @user.id, user: { username: "flop", email: "flop@example.com" }
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "assigns admin rights when requested so" do
        @user = create(:user, admin: false)
        xhr :put, :update, id: @user.id, user: { admin: "1", username: @user.username, email: @user.email }
        assigns[:user].should == @user.reload
        assigns[:user].admin.should == true
        response.should render_template("admin/users/update")
      end

      it "revokes admin rights when requested so" do
        @user = create(:user, admin: true)
        xhr :put, :update, id: @user.id, user: { admin: "0", username: @user.username, email: @user.email }
        assigns[:user].should == @user.reload
        assigns[:user].admin.should == false
        response.should render_template("admin/users/update")
      end
    end

    describe "with invalid params" do
      it "doesn't update the requested user, but assigns it to @user and renders [update] template" do
        @user = create(:user, username: "flip", email: "flip@example.com")

        xhr :put, :update, id: @user.id, user: {}
        assigns[:user].should == @user.reload
        assigns[:user].username.should == "flip"
        response.should render_template("admin/users/update")
      end
    end
  end

  # GET /admin/users/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  describe "GET confirm" do
    it "assigns the requested user as @user and renders [confirm] template" do
      @user = create(:user)

      xhr :get, :confirm, id: @user.id
      assigns[:user].should == @user
      response.should render_template("admin/users/confirm")
    end

    it "reloads current page is the user got deleted" do
      @user = create(:user)
      @user.destroy

      xhr :get, :confirm, id: @user.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "DELETE destroy" do
    it "destroys the requested user and renders [destroy] template" do
      @user = create(:user)

      xhr :delete, :destroy, id: @user.id
      lambda { User.find(@user) }.should raise_error(ActiveRecord::RecordNotFound)
      response.should render_template("admin/users/destroy")
    end

    it "handles the case when the requested user can't be deleted" do
      @user = create(:user)
      @account = create(:account, user: @user) # Plant artifact to prevent the user from being deleted.

      xhr :delete, :destroy, id: @user.id
      flash[:warning].should_not == nil
      expect { User.find(@user) }.not_to raise_error()
      response.should render_template("admin/users/destroy")
    end
  end

  # POST /users/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  describe "POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [ create(:user, first_name: "Hello") ]
    end

    it_should_behave_like("auto complete")
  end

  # PUT /admin/users/1/suspend
  # PUT /admin/users/1/suspend.xml                                         AJAX
  #----------------------------------------------------------------------------
  describe "PUT suspend" do
    it "suspends the requested user" do
      @user = create(:user)

      xhr :put, :suspend, id: @user.id
      assigns[:user].suspended?.should == true
      response.should render_template("admin/users/suspend")
    end

    it "doesn't suspend current user" do
      @user = current_user

      xhr :put, :suspend, id: @user.id
      assigns[:user].suspended?.should == false
      response.should render_template("admin/users/suspend")
    end

    it "reloads current page is the user got deleted" do
      @user = create(:user)
      @user.destroy

      xhr :put, :suspend, id: @user.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end

  # PUT /admin/users/1/reactivate
  # PUT /admin/users/1/reactivate.xml                                      AJAX
  #----------------------------------------------------------------------------
  describe "PUT reactivate" do
    it "re-activates the requested user" do
      @user = create(:user, suspended_at: Time.now.yesterday)

      xhr :put, :reactivate, id: @user.id
      assigns[:user].suspended?.should == false
      response.should render_template("admin/users/reactivate")
    end

    it "reloads current page is the user got deleted" do
      @user = create(:user)
      @user.destroy

      xhr :put, :reactivate, id: @user.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end

end
