class CommentsController < ApplicationController
  before_filter :require_user
  COMMENTABLE = %w(account_id campaign_id contact_id lead_id opportunity_id task_id).freeze

  # GET /comments
  # GET /comments.xml                                           not implemented
  #----------------------------------------------------------------------------
  # def index
  #   @comments = Comment.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @comments }
  #   end
  # end

  # GET /comments/1
  # GET /comments/1.xml                                         not implemented
  #----------------------------------------------------------------------------
  # def show
  #   @comment = Comment.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @comment }
  #   end
  # end

  # GET /comments/new
  # GET /comments/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @comment = Comment.new
    @commentable = extract_commentable_name(params)
    if @commentable
      update_commentable_session
      @commentable.classify.constantize.my(@current_user).find(params["#{@commentable}_id".to_sym])
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @comment }
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if commentable asset was not found.
    respond_to_related_not_found(@commentable, :js)
  end

  # GET /comments/1/edit                                        not implemented
  #----------------------------------------------------------------------------
  # def edit
  #   @comment = Comment.find(params[:id])
  # end

  # POST /comments
  # POST /comments.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @comment = Comment.new(params[:comment])

    # Make sure commentable object exists and is accessible to the current user.
    if @comment.commentable
      @comment.commentable_type.constantize.my(@current_user).find(@comment.commentable.id)
    else
      raise ActiveRecord::RecordNotFound
    end

    respond_to do |format|
      if @comment.save
        format.js   # create.js.rjs
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if commentable asset was not found.
    respond_to_related_not_found(params[:comment][:commentable_type].downcase, :js, :xml)
  end

  # PUT /comments/1
  # PUT /comments/1.xml                                          not implemened
  #----------------------------------------------------------------------------
  # def update
  #   @comment = Comment.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @comment.update_attributes(params[:comment])
  #       flash[:notice] = 'Comment was successfully updated.'
  #       format.html { redirect_to(@comment) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /comments/1
  # DELETE /comments/1.xml                                      not implemented
  #----------------------------------------------------------------------------
  # def destroy
  #   @comment = Comment.find(params[:id])
  #   @comment.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(comments_url) }
  #     format.xml  { head :ok }
  #   end
  # end

  private
  #----------------------------------------------------------------------------
  def extract_commentable_name(params)
    commentable = (params.keys & COMMENTABLE).first
    commentable.sub("_id", "") if commentable
  end

  #----------------------------------------------------------------------------
  def update_commentable_session
    if params[:cancel] == "true"
      session.data.delete("#{@commentable}_new_comment")
    else
      session["#{@commentable}_new_comment"] = true
    end
  end
end
