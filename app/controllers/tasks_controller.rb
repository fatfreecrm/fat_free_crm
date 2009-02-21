class TasksController < ApplicationController
  AJAX_REQUESTS = [ :new, :create, :destroy, :complete, :filter ]
  before_filter :require_user
  before_filter :update_sidebar, :only => :index
  before_filter "set_current_tab(:tasks)", :except => AJAX_REQUESTS

  # GET /tasks
  # GET /tasks.xml
  #----------------------------------------------------------------------------
  def index
    @task = Task.new
    @tasks = Task.find_all_grouped(@current_user, @view)
    @due_at_hint = Setting.task_due_at_hint[1..-1] << [ "Specific date...", :specific_time ]
    @category = Setting.task_category.invert.sort
    @users = User.all_except(@current_user) if @view == "assigned"

    respond_to do |format|
      format.html { render :template => "tasks/index_#{@view}.html.haml" }
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  #----------------------------------------------------------------------------
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  #----------------------------------------------------------------------------
  def new
    @view = params[:view] || "pending"
    @task = Task.new
    @context = "create_#{@view}_task"
    session[@context] = (params[:visible] == "false" ? true : nil)

    respond_to do |format|
      format.js   # new.js.rjs
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  #----------------------------------------------------------------------------
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  #----------------------------------------------------------------------------
  def create
    @task = Task.new(params[:task])
    @view = params[:view] || "pending"
    @context = "create_#{@view}_task"

    respond_to do |format|
      if @task.save
        update_sidebar
        format.js   # create.js.rjs
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.js   # create.js.rjs
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  #----------------------------------------------------------------------------
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(@task) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    # Make sure bucket's div gets hidden if we're deleting last task in the bucket.
    @bucket = Task.bucket(@current_user, params[:bucket],  params[:view])

    update_sidebar
    respond_to do |format|
      format.js   # destroy.js.rjs
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end

  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml
  #----------------------------------------------------------------------------
  def complete
    @task = Task.find(params[:id])
    @task.update_attributes(:completed_at => Time.now)

    # Make sure bucket's div gets hidden if it's the last completed task in the bucket.
    @bucket = Task.bucket(@current_user, params[:bucket])

    update_sidebar
    respond_to do |format|
      format.js   # complete.js.rjs
      format.html { redirect_to(@task) }
      format.xml  { head :ok }
    end
  end

  # Ajax request to filter out list of tasks.
  #----------------------------------------------------------------------------
  def filter
    @view = params[:view]
    update_session do |filters|
      if params[:checked] == "true"
        filters << params[:filter]
      else
        filters.delete(params[:filter])
      end
    end
  end

  private

  # Yields array of current filters and updates the session using new values.
  #----------------------------------------------------------------------------
  def update_session
    name = "filter_by_task_#{@view}"
    filters = (session[name].nil? ? [] : session[name].split(","))
    yield filters
    session[name] = filters.uniq.join(",")
  end

  # Collect data necessary to render filters sidebar.
  #----------------------------------------------------------------------------
  def update_sidebar
    @view = params[:view]
    @view = "pending" unless %w(pending assigned completed).include?(@view)
    @task_total = Task.totals(@current_user, @view)

    # Update filters session if we added, deleted, or completed a task.
    if @task
      update_session do |filters|
        if !@task.deleted_at && !@task.completed_at # created new task
          filters << @task.hint
        elsif @bucket # deleted or completed and need to hide a bucket
          filters.delete(params[:bucket])
        end
      end
    end

    # Create default filters if filters session is empty.
    name = "filter_by_task_#{@view}"
    unless session[name]
      filters = @task_total.keys.select { |key| key != :all && @task_total[key] != 0 }.join(",")
      session[name] = filters unless filters.blank?
    end
  end

end
