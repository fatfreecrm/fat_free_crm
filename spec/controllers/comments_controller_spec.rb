# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe CommentsController do
  COMMENTABLE = %i[account campaign contact lead opportunity].freeze

  before(:each) do
    login
  end

  # GET /comments
  # GET /comments.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do
    COMMENTABLE.each do |asset|
      describe "(HTML)" do
        before(:each) do
          @asset = create(asset)
        end

        it "should redirect to the asset landing page if the asset is found" do
          get :index, params: { "#{asset}_id": @asset.id }
          expect(response).to redirect_to(controller: asset.to_s.pluralize, action: :show, id: @asset.id)
        end

        it "should redirect to root url with warning if the asset is not found" do
          get :index, params: { "#{asset}_id": @asset.id + 42 }
          expect(flash[:warning]).not_to eq(nil)
          expect(response).to redirect_to(root_path)
        end
      end

      describe "(JSON)" do
        before(:each) do
          @asset = create(asset)
          @asset.comments = [create(:comment, commentable: @asset)]
          request.env["HTTP_ACCEPT"] = "application/json"
        end

        it "should render all comments as JSON if the asset is found found" do
          get :index, params: { "#{asset}_id": @asset.id }
          expect(response.body).to eq(assigns[:comments].to_json)
        end

        it "JSON: should return 404 (Not Found) JSON error if the asset is not found" do
          get :index, params: { "#{asset}_id": @asset.id + 42 }
          expect(flash[:warning]).not_to eq(nil)
          expect(response.code).to eq("404")
        end
      end

      describe "(XML)" do
        before(:each) do
          @asset = create(asset)
          @asset.comments = [create(:comment, commentable: @asset)]
          request.env["HTTP_ACCEPT"] = "application/xml"
        end

        it "should render all comments as XML if the asset is found found" do
          get :index, params: { "#{asset}_id": @asset.id }
          expect(response.body).to eq(assigns[:comments].to_xml)
        end

        it "XML: should return 404 (Not Found) XML error if the asset is not found" do
          get :index, params: { "#{asset}_id": @asset.id + 42 }
          expect(flash[:warning]).not_to eq(nil)
          expect(response.code).to eq("404")
        end
      end
    end
  end

  # GET /comments/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    COMMENTABLE.each do |asset|
      it "should expose the requested comment as @commment and render [edit] template" do
        @asset = create(asset)
        @comment = create(:comment, id: 42, commentable: @asset, user: current_user)
        allow(Comment).to receive(:new).and_return(@comment)

        get :edit, params: { id: 42 }, xhr: true
        expect(assigns[:comment]).to eq(@comment)
        expect(response).to render_template("comments/edit")
      end
    end
  end

  # POST /comments
  # POST /comments.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do
    describe "with valid params" do
      COMMENTABLE.each do |asset|
        it "should expose a newly created comment as @comment for the #{asset}" do
          @asset = create(asset)
          @comment = build(:comment, commentable: @asset, user: current_user)
          allow(Comment).to receive(:new).and_return(@comment)

          post :create, params: { comment: { commentable_type: asset.to_s.classify, commentable_id: @asset.id, user_id: current_user.id, comment: "Hello" } }, xhr: true
          expect(assigns[:comment]).to eq(@comment)
          expect(response).to render_template("comments/create")
        end
      end
    end

    describe "with invalid params" do
      COMMENTABLE.each do |asset|
        it "should expose a newly created but unsaved comment as @comment for #{asset}" do
          @asset = create(asset)
          @comment = build(:comment, commentable: @asset, user: current_user)
          allow(Comment).to receive(:new).and_return(@comment)

          post :create, params: { comment: {} }, xhr: true
          expect(assigns[:comment]).to eq(@comment)
          expect(response).to render_template("comments/create")
        end
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml                                          not implemened
  #----------------------------------------------------------------------------
  # describe "responding to PUT update" do
  #
  #   describe "with valid params" do
  #     it "should update the requested comment" do
  #       Comment.should_receive(:find).with("37").and_return(mock_comment)
  #       mock_comment.should_receive(:update).with({'these' => 'params'})
  #       put :update, :id => "37", :comment => {:these => 'params'}
  #     end
  #
  #     it "should expose the requested comment as @comment" do
  #       Comment.stub(:find).and_return(mock_comment(:update => true))
  #       put :update, :id => "1"
  #       assigns(:comment).should equal(mock_comment)
  #     end
  #
  #     it "should redirect to the comment" do
  #       Comment.stub(:find).and_return(mock_comment(:update => true))
  #       put :update, :id => "1"
  #       response.should redirect_to(comment_path(mock_comment))
  #     end
  #   end
  #
  #   describe "with invalid params" do
  #     it "should update the requested comment" do
  #       Comment.should_receive(:find).with("37").and_return(mock_comment)
  #       mock_comment.should_receive(:update).with({'these' => 'params'})
  #       put :update, :id => "37", :comment => {:these => 'params'}
  #     end
  #
  #     it "should expose the comment as @comment" do
  #       Comment.stub(:find).and_return(mock_comment(:update => false))
  #       put :update, :id => "1"
  #       assigns(:comment).should equal(mock_comment)
  #     end
  #
  #     it "should re-render the 'edit' template" do
  #       Comment.stub(:find).and_return(mock_comment(:update => false))
  #       put :update, :id => "1"
  #       response.should render_template('edit')
  #     end
  #   end
  #
  # end

  # DELETE /comments/1
  # DELETE /comments/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    describe "AJAX request" do
      describe "with valid params" do
        COMMENTABLE.each do |asset|
          it "should destroy the requested comment and render [destroy] template" do
            @asset = create(asset)
            @comment = create(:comment, commentable: @asset, user: current_user)
            allow(Comment).to receive(:new).and_return(@comment)

            delete :destroy, params: { id: @comment.id }, xhr: true
            expect { Comment.find(@comment.id) }.to raise_error(ActiveRecord::RecordNotFound)
            expect(response).to render_template("comments/destroy")
          end
        end
      end
    end
  end
end
