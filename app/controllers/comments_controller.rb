# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class CommentsController < ApplicationController
  before_filter :require_user

  respond_to :js
  respond_to :json, :xml, :except => :edit

  COMMENTABLE = %w(account_id campaign_id contact_id lead_id opportunity_id task_id).freeze

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
      format.json { render :text => flash[:warning], :status => :not_found }
      format.xml  { render :text => flash[:warning], :status => :not_found }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  # GET /comments/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @comment = Comment.new
    @commentable = extract_commentable_name(params)

    if @commentable
      update_commentable_session
      @commentable.classify.constantize.my.find(params[:"#{@commentable}_id"])
    end

    respond_with(@comment)

  rescue ActiveRecord::RecordNotFound # Kicks in if commentable asset was not found.
    respond_to_related_not_found(@commentable, :js)
  end

  # GET /comments/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @comment = Comment.find(params[:id])

    if @comment.commentable
      @comment.commentable_type.constantize.my.find(@comment.commentable.id)
    else
      raise ActiveRecord::RecordNotFound
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if commentable asset was not found.
    respond_to_related_not_found(params[:comment][:commentable_type].downcase, :js, :xml)
  end

  # POST /comments
  # POST /comments.json
  # POST /comments.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @comment = Comment.new(params[:comment])

    # Make sure commentable object exists and is accessible to the current user.
    if @comment.commentable
      @comment.commentable_type.constantize.my.find(@comment.commentable.id)
    else
      raise ActiveRecord::RecordNotFound
    end

    @comment.save
    respond_with(@comment)

  rescue ActiveRecord::RecordNotFound # Kicks in if commentable asset was not found.
    respond_to_related_not_found(params[:comment][:commentable_type].downcase, :js, :xml)
  end

  # PUT /comments/1
  # PUT /comments/1.json
  # PUT /comments/1.xml                                          not implemened
  #----------------------------------------------------------------------------
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    respond_with(@comment)

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  # DELETE /comments/1.xml                                      not implemented
  #----------------------------------------------------------------------------
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_with(@comment)

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  private
  #----------------------------------------------------------------------------
  def extract_commentable_name(params)
    commentable = (params.keys & COMMENTABLE).first
    commentable.sub("_id", "") if commentable
  end

  #----------------------------------------------------------------------------
  def update_commentable_session
    if params[:cancel].true?
      session.delete("#{@commentable}_new_comment")
    else
      session["#{@commentable}_new_comment"] = true
    end
  end
end
