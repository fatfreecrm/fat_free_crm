# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthenticationsController do
  before(:each) do
    activate_authlogic
    logout
  end

  # Authentication filters
  #----------------------------------------------------------------------------
  describe "authentication filters" do
    describe "user must not be logged" do
      describe "DELETE authentication (logout form)" do
        it "displays 'must be logged out message' and redirects to login page" do
          delete :destroy
          expect(flash[:notice]).not_to eq(nil)
          expect(flash[:notice]).to match(/^You must be logged in/)
          expect(response).to redirect_to(login_path)
        end

        it "redirects to login page" do
          get :show
          expect(response).to redirect_to(login_path)
        end
      end
    end

    describe "user must not be logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass")
        allow(@controller).to receive(:current_user).and_return(@user)
      end

      describe "GET authentication (login form)" do
        it "displays 'must be logged out message' and redirects to profile page" do
          get :new
          expect(flash[:notice]).not_to eq(nil)
          expect(flash[:notice]).to match(/^You must be logged out/)
          expect(response).to redirect_to(profile_path)
        end
      end

      describe "POST authentication" do
        it "displays 'must be logged out message' and redirects to profile page" do
          post :create, params: { authentication: @login }
          expect(flash[:notice]).not_to eq(nil)
          expect(flash[:notice]).to match(/^You must be logged out/)
          expect(response).to redirect_to(profile_path)
        end
      end
    end
  end

  # POST /authentications
  # POST /authentications.xml                                              HTML
  #----------------------------------------------------------------------------
  describe "POST authentications" do
    before(:each) do
      @login = { username: "user", password: "pass", remember_me: "0" }
      @authentication = double(Authentication, @login)
    end

    describe "successful authentication " do
      before(:each) do
        allow(@authentication).to receive(:save).and_return(true)
        allow(Authentication).to receive(:new).and_return(@authentication)
      end

      it "displays welcome message and redirects to the home page" do
        @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass", login_count: 0)
        allow(@authentication).to receive(:user).and_return(@user)

        post :create, params: { authentication: @login }
        expect(flash[:notice]).not_to eq(nil)
        expect(flash[:notice]).not_to match(/last login/)
        expect(response).to redirect_to(root_path)
      end

      it "displays last login time if it's not the first login" do
        @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass", login_count: 42)
        allow(@authentication).to receive(:user).and_return(@user)

        post :create, params: { authentication: @login }
        expect(flash[:notice]).to match(/last login/)
        expect(response).to redirect_to(root_path)
      end
    end

    describe "authenticaion failure" do
      describe "user is not suspended" do
        it "redirects to login page if username or password are invalid" do
          @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass")
          allow(@authentication).to receive(:user).and_return(@user)
          allow(@authentication).to receive(:save).and_return(false) # <--- Authentication failure.
          allow(Authentication).to receive(:new).and_return(@authentication)

          post :create, params: { authentication: @login }
          expect(flash[:warning]).not_to eq(nil)
          expect(response).to redirect_to(action: :new)
        end
      end

      describe "user has been suspended" do
        before(:each) do
          allow(@authentication).to receive(:save).and_return(true)
          allow(Authentication).to receive(:new).and_return(@authentication)
        end

        # This tests :before_save update_info callback in Authentication model.
        it "keeps user login attributes intact" do
          @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass", suspended_at: Date.yesterday, login_count: 0, last_login_at: nil, last_login_ip: nil)
          allow(@authentication).to receive(:user).and_return(@user)

          post :create, params: { authentication: @login }
          expect(@authentication.user.login_count).to eq(0)
          expect(@authentication.user.last_login_at).to be_nil
          expect(@authentication.user.last_login_ip).to be_nil
        end

        it "redirects to login page if user is suspended" do
          @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass", suspended_at: Date.yesterday)
          allow(@authentication).to receive(:user).and_return(@user)

          post :create, params: { authentication: @login }
          expect(flash[:warning]).not_to eq(nil) # Invalid username/password.
          expect(flash[:notice]).to eq(nil)      # Not approved yet.
          expect(response).to redirect_to(action: :new)
        end

        it "redirects to login page with the message if signup needs approval and user hasn't been activated yet" do
          allow(Setting).to receive(:user_signup).and_return(:needs_approval)
          @user = FactoryGirl.create(:user, username: "user", password: "pass", password_confirmation: "pass", suspended_at: Date.yesterday, login_count: 0)
          allow(@authentication).to receive(:user).and_return(@user)

          post :create, params: { authentication: @login }
          expect(flash[:warning]).to eq(nil)     # Invalid username/password.
          expect(flash[:notice]).not_to eq(nil)  # Not approved yet.
          expect(response).to redirect_to(action: :new)
        end
      end
    end # authentication failure
  end # POST authenticate
end
