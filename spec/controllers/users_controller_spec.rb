# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe UsersController do
  # GET /users/1
  # GET /users/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do
    before(:each) do
      login
    end

    it "should render [show] template" do
      get :show, params: { id: current_user.id }
      expect(assigns[:user]).to eq(current_user)
      expect(response).to render_template("users/show")
    end

    it "should expose current user as @user if no specific user was requested" do
      get :show
      expect(assigns[:user]).to eq(current_user)
      expect(response).to render_template("users/show")
    end

    it "should show user if admin user" do
      @user = create(:user)
      login_admin
      get :show, params: { id: @user.id }
      expect(assigns[:user]).to eq(@user)
      expect(response).to render_template("users/show")
    end

    it "should not show user if not admin user" do
      @user = create(:user)
      get :show, params: { id: @user.id }
      expect(response).to redirect_to(root_url)
    end

    describe "with mime type of JSON" do
      before(:each) do
        request.env["HTTP_ACCEPT"] = "application/json"
      end

      it "should render the requested user as JSON" do
        expect(User).to receive(:find).and_return(current_user)
        expect_any_instance_of(User).to receive(:to_json).and_return("generated JSON")
        get :show, params: { id: current_user.id }
        expect(response.body).to eq("generated JSON")
      end

      it "should render current user as JSON if no specific user was requested" do
        expect_any_instance_of(User).to receive(:to_json).and_return("generated JSON")

        get :show
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of xml" do
      before(:each) do
        request.env["HTTP_ACCEPT"] = "application/xml"
      end

      it "should render the requested user as XML" do
        expect(User).to receive(:find).and_return(current_user)
        expect_any_instance_of(User).to receive(:to_xml).and_return("generated XML")

        get :show, params: { id: current_user.id }
        expect(response.body).to eq("generated XML")
      end

      it "should render current user as XML if no specific user was requested" do
        expect_any_instance_of(User).to receive(:to_xml).and_return("generated XML")

        get :show
        expect(response.body).to eq("generated XML")
      end
    end
  end

  # GET /users/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose current user as @user and render [edit] template" do
      login
      @user = current_user
      get :edit, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(current_user)
      expect(response).to render_template("users/edit")
    end

    it "should not allow current user to edit another user" do
      @user = create(:user)
      login
      get :edit, params: { id: @user.id }, xhr: true
      expect(response.body).to eql("window.location.reload();")
    end

    it "should allow admin to edit another user" do
      login_admin
      @user = create(:user)
      get :edit, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(@user)
      expect(response).to render_template("users/edit")
    end
  end

  # PUT /users/1
  # PUT /users/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do
    before(:each) do
      login
      @user = current_user
    end

    describe "with valid params" do
      it "should update user information and render [update] template" do
        put :update, params: { id: @user.id, user: { first_name: "Billy", last_name: "Bones" } }, xhr: true
        @user.reload
        expect(@user.first_name).to eq("Billy")
        expect(@user.last_name).to eq("Bones")
        expect(assigns[:user]).to eq(@user)
        expect(response).to render_template("users/update")
      end
    end

    describe "with invalid params" do
      it "should not update the user information and redraw [update] template" do
        put :update, params: { id: @user.id, user: { first_name: nil } }, xhr: true
        expect(@user.reload.first_name).to eq(current_user.first_name)
        expect(assigns[:user]).to eq(@user)
        expect(response).to render_template("users/update")
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml                HTML and AJAX (not directly exposed yet)
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      login
    end

    it "should destroy the requested user" do
    end

    it "should redirect to the users list" do
    end
  end

  # GET /users/1/avatar
  # GET /users/1/avatar.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET avatar" do
    before(:each) do
      login
      @user = current_user
    end

    it "should expose current user as @user and render [avatar] template" do
      get :avatar, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(current_user)
      expect(response).to render_template("users/avatar")
    end
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.xml                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update_avatar" do
    before(:each) do
      login
      @user = current_user
    end

    it "should delete avatar if user chooses to use Gravatar" do
      @avatar = create(:avatar, user: @user, entity: @user)

      put :upload_avatar, params: { id: @user.id, gravatar: 1 }, xhr: true
      expect(@user.reload.avatar).to eq(nil)
      expect(response).to render_template("users/upload_avatar")
    end

    it "should do nothing if user hasn't specified the avatar file to upload" do
      @avatar = create(:avatar, user: @user, entity: @user)

      put :upload_avatar, params: { id: @user.id }, xhr: true
      expect(@user.avatar).to eq(@avatar)
      expect(response).to render_template("users/upload_avatar")
    end

    it "should save the user avatar if it was successfully uploaded and resized" do
      @image = fixture_file_upload('/rails.png', 'image/png')

      put :upload_avatar, params: { id: @user.id, avatar: { image: @image } }, xhr: true
      expect(@user.avatar).not_to eq(nil)
      expect(@user.avatar.image_file_size).to eq(@image.size)
      expect(@user.avatar.image_file_name).to eq(@image.original_filename)
      expect(@user.avatar.image_content_type).to eq(@image.content_type)
      expect(response).to render_template("users/upload_avatar")
    end

    # -------------------------- Fix later --------------------------------
    #    it "should return errors if the avatar failed to get uploaded and resized" do
    #      @image = fixture_file_upload("spec/fixtures/rails.png", "image/png")
    #      @user.stub(:save).and_return(false) # make it fail

    #      put :upload_avatar, :id => @user.id, :avatar => { :image => @image }
    #      @user.avatar.errors.should_not be_empty
    #      @user.avatar.should have(1).error # .error_on(:image)
    #      response.should render_template("users/upload_avatar")
    #    end
  end

  # GET /users/1/password
  # GET /users/1/password.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET avatar" do
    before(:each) do
      login
      @user = current_user
    end

    it "should expose current user as @user and render [pssword] template" do
      get :password, params: { id: @user.id }, xhr: true
      expect(assigns[:user]).to eq(current_user)
      expect(response).to render_template("users/password")
    end
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.xml                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT change_password" do
    before(:each) do
      @old_password = 'foobar123'
      @user = FactoryBot.create(:user, password: @old_password, password_confirmation: @old_password)
      perform_login(@user)
      @old_encrypted_password = @user.encrypted_password
      @new_password = 'secret?!'
    end

    it "should set new user password" do
      put :change_password, params: { id: @user.id, current_password: @old_password, user: { password: @new_password, password_confirmation: @new_password } }, xhr: true
      expect(assigns[:user]).to eq(@user)
      expect(assigns[:user].password).to eq('secret?!')
      expect(assigns[:user].errors).to be_empty
      expect(assigns[:user].reload.encrypted_password).to_not eq(@old_encrypted_password) # password change
      expect(response).to render_template("users/change_password")
    end

    it "should not allow to change password if current password is blank" do
      current_user.encrypted_password = nil
      put :change_password, params: { id: @user.id, current_password: "", user: { password: @new_password, password_confirmation: @new_password } }, xhr: true
      expect(assigns[:user].password).to eq(nil)
      expect(assigns[:user].errors.size).to eq(1) # .error_on(:current_password)
      expect(assigns[:user].reload.encrypted_password).to eq(@old_encrypted_password) # password stays the same
      expect(response).to render_template("users/change_password")
    end

    it "should not change user password if password field is blank" do
      put :change_password, params: { id: @user.id, current_password: @old_password, user: { password: "", password_confirmation: "" } }, xhr: true
      expect(assigns[:user]).to eq(current_user)
      expect(assigns[:user].password).to eq(nil)
      expect(assigns[:user].errors).to be_empty # no errors
      expect(assigns[:user].reload.encrypted_password).to eq(@old_encrypted_password) # password stays the same
      expect(response).to render_template("users/change_password")
    end

    it "should require valid current password" do
      put :change_password, params: { id: @user.id, current_password: "what?!", user: { password: @new_password, password_confirmation: @new_password } }, xhr: true
      expect(assigns[:user].password).to eq(nil)
      expect(assigns[:user].errors.size).to eq(1) # .error_on(:current_password)
      expect(assigns[:user].reload.encrypted_password).to eq(@old_encrypted_password) # password stays the same
      expect(response).to render_template("users/change_password")
    end

    it "should require new password and password confirmation to match" do
      put :change_password, params: { id: @user.id, current_password: @old_password, user: { password: @new_password, password_confirmation: "none" } }, xhr: true
      expect(assigns[:user].password).to eq('secret?!')
      expect(assigns[:user].errors.size).to eq(1) # .error_on(:current_password)
      expect(assigns[:user].reload.encrypted_password).to eq(@old_encrypted_password) # password stays the same
      expect(response).to render_template("users/change_password")
    end
  end

  # GET /users/opportunities
  # GET /users/opportunities.xml                                         HTML
  #----------------------------------------------------------------------------
  describe "responding to GET opportunities_overview" do
    before(:each) do
      login
      @user = current_user
      @user.update_attributes(first_name: "Apple", last_name: "Boy")
    end

    it "should assign @users_with_opportunities" do
      create(:opportunity, stage: "prospecting", assignee: @user)
      get :opportunities_overview, xhr: true
      expect(assigns[:users_with_opportunities]).to eq([@user])
    end

    it "@users_with_opportunities should be ordered by name" do
      create(:opportunity, stage: "prospecting", assignee: @user)

      user1 = create(:user, first_name: "Zebra", last_name: "Stripes")
      create(:opportunity, stage: "prospecting", assignee: user1)

      user2 = create(:user, first_name: "Bilbo", last_name: "Magic")
      create(:opportunity, stage: "prospecting", assignee: user2)

      get :opportunities_overview, xhr: true

      expect(assigns[:users_with_opportunities]).to eq([@user, user2, user1])
    end

    it "should assign @unassigned_opportunities with only open unassigned opportunities" do
      @o1 = create(:opportunity, stage: "prospecting", assignee: nil)
      @o2 = create(:opportunity, stage: "won", assignee: nil)
      @o3 = create(:opportunity, stage: "prospecting", assignee: nil)

      get :opportunities_overview, xhr: true

      expect(assigns[:unassigned_opportunities]).to include(@o1, @o3)
      expect(assigns[:unassigned_opportunities]).not_to include(@o2)
    end

    it "@unassigned_opportunities should be ordered by stage" do
      @o1 = create(:opportunity, stage: "proposal", assignee: nil)
      @o2 = create(:opportunity, stage: "prospecting", assignee: nil)
      @o3 = create(:opportunity, stage: "negotiation", assignee: nil)

      get :opportunities_overview, xhr: true

      expect(assigns[:unassigned_opportunities]).to eq([@o3, @o1, @o2])
    end

    it "should not include users who have no assigned opportunities" do
      get :opportunities_overview, xhr: true
      expect(assigns[:users_with_opportunities]).to eq([])
    end

    it "should not include users who have no open assigned opportunities" do
      create(:opportunity, stage: "won", assignee: @user)

      get :opportunities_overview, xhr: true
      expect(assigns[:users_with_opportunities]).to eq([])
    end

    it "should render opportunities overview" do
      get :opportunities_overview, xhr: true
      expect(response).to render_template("users/opportunities_overview")
    end
  end
end
