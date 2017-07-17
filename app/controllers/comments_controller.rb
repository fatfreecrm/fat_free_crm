# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CommentsController < ApplicationController
  before_action :require_user

  # GET /comments
  # GET /comments.json
  # GET /comments.xml
  #----------------------------------------------------------------------------
  def index
    @commentable = extract_commentable_name(params)
    if @commentable
      @asset = @commentable.classify.constantize.my.find(params[:"#{@commentable}_id"])
      @comments = @asset.comments.order("created_at DESC")
    end
    respond_with(@comments) do |format|
      format.html { redirect_to @asset }
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if @asset was not found.
    flash[:warning] = t(:msg_assets_not_available, "notes")
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render plain: flash[:warning], status: :not_found }
      format.xml  { render plain: flash[:warning], status: :not_found }
    end
  end

  # GET /comments/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @comment = Comment.find(params[:id])

    model = @comment.commentable_type
    id = @comment.commentable_id
    unless model.constantize.my.find_by_id(id)
      respond_to_related_not_found(model.downcase)
    end
  end

  # POST /comments
  # POST /comments.json
  # POST /comments.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @comment = Comment.new(
      comment_params.merge(user_id: current_user.id)
    )
    # Make sure commentable object exists and is accessible to the current user.
    model = @comment.commentable_type
    id = @comment.commentable_id
    if model.constantize.my.find_by_id(id)
      @comment.save
      respond_with(@comment)
    else
      respond_to_related_not_found(model.downcase)
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  # PUT /comments/1.xml                                          not implemened
  #----------------------------------------------------------------------------
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(comment_params)
    respond_with(@comment)
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  # DELETE /comments/1.xml                                      not implemented
  #----------------------------------------------------------------------------
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_with(@comment)
  end

  protected

  def comment_params
    return {} unless params[:comment]
    params[:comment].permit!
  end

  private

  #----------------------------------------------------------------------------
  def extract_commentable_name(params)
    params.keys.detect { |x| x =~ /_id$/ }.try(:sub, /_id$/, '')
  end
end
