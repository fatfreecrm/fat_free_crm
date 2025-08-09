# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
      @users = [current_user, create(:user)]

      get :index
      expect(assigns[:users].first).to eq(@users.last) # get_users() sorts by id DESC
      expect(assigns[:users].last).to eq(@users.first)
      expect(response).to render_template("admin/users/index")
    end

    it "performs lookup using query string" do
      @amy = create(:user, username: "amy_anderson")
      @bob = create(:user, username: "bob_builder")

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
      @user = create(:user)

      get :show, params: { id: @user.id }
      expect(assigns[:user]).to eq(@user)
      expect(response).to render_template("admin/users/show")
    end
  end

  # GET /admin/users/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  describe "GET edit" do
    it "assigns the requested user as @user and renders [edit] template" do
      @user = create(:user)

      get :edit, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(@user)
      expect(assigns[:previous]).to eq(nil)
      expect(response).to render_template("admin/users/edit")
    end

    it "assigns the previous user as @previous when necessary" do
      @user = create(:user)
      @previous = create(:user)

      get :edit, params: { id: @user.id, previous: @previous.id }, xhr: true
      expect(assigns[:previous]).to eq(@previous)
    end

    it "reloads current page with the flash message if user got deleted" do
      @user = create(:user)
      @user.destroy

      get :edit, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect(response.body).to eq("window.location.reload();")
    end

    it "notifies the view if previous user got deleted" do
      @user = create(:user)
      @previous = create(:user)
      @previous.destroy

      get :edit, params: { id: @user.id, previous: @previous.id }, xhr: true
      expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
      expect(assigns[:previous]).to eq(@previous.id)
      expect(response).to render_template("admin/users/edit")
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user, assigns it to @user, and renders [update] template" do
        @user = create(:user, username: "flip", email: "flip@example.com")

        put :update, params: { id: @user.id, user: { username: "flop", email: "flop@example.com" } }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].username).to eq("flop")
        expect(response).to render_template("admin/users/update")
      end

      it "reloads current page is the user got deleted" do
        @user = create(:user)
        @user.destroy

        put :update, params: { id: @user.id, user: { username: "flop", email: "flop@example.com" } }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "assigns admin rights when requested so" do
        @user = create(:user, admin: false)
        put :update, params: { id: @user.id, user: { admin: "1", username: @user.username, email: @user.email } }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].admin).to eq(true)
        expect(response).to render_template("admin/users/update")
      end

      it "revokes admin rights when requested so" do
        @user = create(:user, admin: true)
        put :update, params: { id: @user.id, user: { admin: "0", username: @user.username, email: @user.email } }, xhr: true
        expect(assigns[:user]).to eq(@user.reload)
        expect(assigns[:user].admin).to eq(false)
        expect(response).to render_template("admin/users/update")
      end
    end

    describe "with invalid params" do
      it "doesn't update the requested user, but assigns it to @user and renders [update] template" do
        @user = create(:user, username: "flip", email: "flip@example.com")

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
      @user = create(:user)

      get :confirm, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(@user)
      expect(response).to render_template("admin/users/confirm")
    end

    it "reloads current page is the user got deleted" do
      @user = create(:user)
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
      @user = create(:user)

      delete :destroy, params: { id: @user.id }, xhr: true
      expect { User.find(@user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to render_template("admin/users/destroy")
    end

    it "handles the case when the requested user can't be deleted" do
      @user = create(:user)
      @account = create(:account, user: @user) # Plant artifact to prevent the user from being deleted.

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
      @auto_complete_matches = [create(:user, first_name: "Hello")]
    end

    it_should_behave_like("auto complete")
  end

  # PUT /admin/users/1/suspend
  # PUT /admin/users/1/suspend.xml                                         AJAX
  #----------------------------------------------------------------------------
  describe "PUT suspend" do
    it "suspends the requested user" do
      @user = create(:user)

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
      @user = create(:user)
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
      @user = create(:user, suspended_at: Time.now.yesterday)

      put :reactivate, params: { id: @user.id }, xhr: true
      expect(assigns[:user].suspended?).to eq(false)
      expect(response).to render_template("admin/users/reactivate")
    end

    it "reloads current page is the user got deleted" do
      @user = create(:user)
      @user.destroy

      put :reactivate, params: { id: @user.id }, xhr: true
      expect(flash[:warning]).not_to eq(nil)
      expect(response.body).to eq("window.location.reload();")
    end
  end
end
