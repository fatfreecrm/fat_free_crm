class CommentsController < ApplicationController
  COMMENTABLE = %w(account_id campaign_id contact_id lead_id opportunity_id task_id).freeze

  # GET /comments
  # GET /comments.xml
  #----------------------------------------------------------------------------
  def index
    @comments = Comment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  #----------------------------------------------------------------------------
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  #----------------------------------------------------------------------------
  def new
    @comment = Comment.new
    @commentable = extract_commentable_name(params)
    session["#{@commentable}_new_comment"] = (params[:cancel] == "true" ? nil : true) if @commentable

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  #----------------------------------------------------------------------------
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  #----------------------------------------------------------------------------
  def create
    @comment = Comment.new(params[:comment])

    respond_to do |format|
      if @comment.save
        format.js   # create.js.rjs
        format.html { redirect_to(@comment) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.js   # create.js.rjs
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  #----------------------------------------------------------------------------
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end

  private
  #----------------------------------------------------------------------------
  def extract_commentable_name(params)
    commentable = (params.keys & COMMENTABLE).first
    commentable.sub("_id", "") if commentable
  end

end
