# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  before(:each) do
    require_user(admin: true)
    set_current_tab(:users)
  end

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  describe "GET index" do
    it "assigns all users as @users and renders [index] template" do
      @users = [current_user, FactoryGirl.create(:user)]

      get :index
      expect(assigns[:users].first).to eq(@users.last) # get_users() sorts by id DESC
      expect(assigns[:users].last).to eq(@users.first)
      expect(response).to render_template("admin/users/index")
    end

    it "performs lookup using query string" do
      @amy = FactoryGirl.create(:user, username: "amy_anderson")
      @bob = FactoryGirl.create(:user, username: "bob_builder")

      get :index, params: { query: "amy_anderson" }
      expect(assigns[:users]).to eq([@amy])
      expect(assigns[:current_query]).to eq("amy_anderson")
      expect(session[:users_current_query]).to eq("amy_anderson")
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  #----------------------------------------------------------------------------
  describe "GET show" do
    it "assigns the requested user as @user and renders [show] template" do
      @user = FactoryGirl.create(:user)

      get :show, params: { id: @user.id }
      expect(assigns[:user]).to eq(@user)
      expect(response).to render_template("admin/users/show")
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "GET new" do
    it "assigns a new user as @user and renders [new] template" do
      get :new, xhr: true
      expect(assigns[:user]).to be_new_record
      expect(response).to render_template("admin/users/new")
    end
  end

  # GET /admin/users/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  describe "GET edit" do
    it "assigns the requested user as @user and renders [edit] template" do
      @user = FactoryGirl.create(:user)

      get :edit, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(@user)
      expect(assigns[:previous]).to eq(nil)
      expect(response).to render_template("admin/users/edit")
    end

    it "assigns the previous user as @previous when necessary" do
      @user = FactoryGirl.create(:user)
      @previous = FactoryGirl.create(:user)

      get :edit, params: { id: @user.id, previous: @previous.id }, xhr: true
      expect(assigns[:previous]).to eq(@previous)
    end

    it "reloads current page with the flash message if user got deleted" do
      @user = FactoryGirl.create(:user)
      @user.destroy

      get :edit, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect(response.body).to eq("window.location.reload();")
    end

    it "notifies the view if previous user got deleted" do
      @user = FactoryGirl.create(:user)
      @previous = FactoryGirl.create(:user)
      @previous.destroy

      get :edit, params: { id: @user.id, previous: @previous.id }, xhr: true
      expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
      expect(assigns[:previous]).to eq(@previous.id)
      expect(response).to render_template("admin/users/edit")
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
        @user = FactoryGirl.build(:user, username: @username, email: @email)
        allow(User).to receive(:new).and_return(@user)

        post :create, params: { user: { username: @username, email: @email, password: @password, password_confirmation: @password } }, xhr: true
        expect(assigns[:user]).to eq(@user)
        expect(response).to render_template("admin/users/create")
      end

      it "creates admin user when requested so" do
        post :create, params: { user: { username: @username, email: @email, admin: "1", password: @password, password_confirmation: @password } }, xhr: true
        expect(assigns[:user].admin).to eq(true)
        expect(response).to render_template("admin/users/create")
      end

      it "doesn't create admin user unless requested so" do
        post :create, params: { user: { username: @username, email: @email, admin: "0", password: @password, password_confirmation: @password } }, xhr: true
        expect(assigns[:user].admin).to eq(false)
        expect(response).to render_template("admin/users/create")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user and re-renders [create] template" do
        @user = FactoryGirl.build(:user, username: "", email: "")
        allow(User).to receive(:new).and_return(@user)

        post :create, params: { user: {} }, xhr: true
        expect(assigns[:user]).to eq(@user)
        expect(response).to render_template("admin/users/create")
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user, assigns it to @user, and renders [update] template" do
        @user = FactoryGirl.create(:user, username: "flip", email: "flip@example.com")

        put :update, params: { id: @user.id, user: { username: "flop", email: "flop@example.com" } }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].username).to eq("flop")
        expect(response).to render_template("admin/users/update")
      end

      it "reloads current page is the user got deleted" do
        @user = FactoryGirl.create(:user)
        @user.destroy

        put :update, params: { id: @user.id, user: { username: "flop", email: "flop@example.com" } }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "assigns admin rights when requested so" do
        @user = FactoryGirl.create(:user, admin: false)
        put :update, params: { id: @user.id, user: { admin: "1", username: @user.username, email: @user.email } }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].admin).to eq(true)
        expect(response).to render_template("admin/users/update")
      end

      it "revokes admin rights when requested so" do
        @user = FactoryGirl.create(:user, admin: true)
        put :update, params: { id: @user.id, user: { admin: "0", username: @user.username, email: @user.email } }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].admin).to eq(false)
        expect(response).to render_template("admin/users/update")
      end
    end

    describe "with invalid params" do
      it "doesn't update the requested user, but assigns it to @user and renders [update] template" do
        @user = FactoryGirl.create(:user, username: "flip", email: "flip@example.com")

        put :update, params: { id: @user.id, user: {} }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].username).to eq("flip")
        expect(response).to render_template("admin/users/update")
      end
    end
  end

  # GET /admin/users/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  describe "GET confirm" do
    it "assigns the requested user as @user and renders [confirm] template" do
      @user = FactoryGirl.create(:user)

      get :confirm, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(@user)
      expect(response).to render_template("admin/users/confirm")
    end

    it "reloads current page is the user got deleted" do
      @user = FactoryGirl.create(:user)
      @user.destroy

      get :confirm, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect(response.body).to eq("window.location.reload();")
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "DELETE destroy" do
    it "destroys the requested user and renders [destroy] template" do
      @user = FactoryGirl.create(:user)

      delete :destroy, params: { id: @user.id }, xhr: true
      expect { User.find(@user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to render_template("admin/users/destroy")
    end

    it "handles the case when the requested user can't be deleted" do
      @user = FactoryGirl.create(:user)
      @account = FactoryGirl.create(:account, user: @user) # Plant artifact to prevent the user from being deleted.

      delete :destroy, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect { User.find(@user.id) }.not_to raise_error
      expect(response).to render_template("admin/users/destroy")
    end
  end

  # POST /users/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  describe "POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [FactoryGirl.create(:user, first_name: "Hello")]
    end

    it_should_behave_like("auto complete")
  end

  # PUT /admin/users/1/suspend
  # PUT /admin/users/1/suspend.xml                                         AJAX
  #----------------------------------------------------------------------------
  describe "PUT suspend" do
    it "suspends the requested user" do
      @user = FactoryGirl.create(:user)

      put :suspend, params: { id: @user.id }, xhr: true
      expect(assigns[:user].suspended?).to eq(true)
      expect(response).to render_template("admin/users/suspend")
    end

    it "doesn't suspend current user" do
      @user = current_user

      put :suspend, params: { id: @user.id }, xhr: true
      expect(assigns[:user].suspended?).to eq(false)
      expect(response).to render_template("admin/users/suspend")
    end

    it "reloads current page is the user got deleted" do
      @user = FactoryGirl.create(:user)
      @user.destroy

      put :suspend, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect(response.body).to eq("window.location.reload();")
    end
  end

  # PUT /admin/users/1/reactivate
  # PUT /admin/users/1/reactivate.xml                                      AJAX
  #----------------------------------------------------------------------------
  describe "PUT reactivate" do
    it "re-activates the requested user" do
      @user = FactoryGirl.create(:user, suspended_at: Time.now.yesterday)

      put :reactivate, params: { id: @user.id }, xhr: true
      expect(assigns[:user].suspended?).to eq(false)
      expect(response).to render_template("admin/users/reactivate")
    end

    it "reloads current page is the user got deleted" do
      @user = FactoryGirl.create(:user)
      @user.destroy

      put :reactivate, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect(response.body).to eq("window.location.reload();")
    end
  end
end
