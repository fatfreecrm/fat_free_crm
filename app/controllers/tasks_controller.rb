class TasksController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => [ :index, :destroy, :complete ]
  before_filter "set_current_tab(:tasks)"

  # GET /tasks
  # GET /tasks.xml
  #----------------------------------------------------------------------------
  def index
    @task = Task.new
    @tasks = Task.list(@current_user, @view, session["filter_by_task_#{@view}"])
    @due_date = Setting.task_due_date[1..-1] << [ "On specific date...", :on_specific_date ]
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
    session["tasks_new_#{@view}"] = (params[:visible] == "false" ? true : nil)

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

    respond_to do |format|
      if @task.save
        get_data_for_sidebar
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
    @view = "pending" unless %w(pending assigned completed).include?(@view)
    @category = Setting.task_category.invert.sort

    name = "filter_by_task_#{@view}"
    old_filters   = (session[name].nil? ? [] : session[name].split(","))
    new_filters   = params[:filters].split(",")
    session[name] = params[:filters]

    @tasks = Task.filter(@current_user, @view, old_filters, new_filters)
  end

  private

  # Dispatch to appropriate sidebar handler, then save filters with non-zero
  # task counts in a session.
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @view = params[:view]
    @view = "pending" unless %w(pending assigned completed).include?(@view)
    @task_total = Task.totals(@current_user, @view)

    name = "filter_by_task_#{@view}"
    unless session[name]
      filters = @task_total.keys.select { |key| key != :all && @task_total[key] != 0 }.join(",")
      session[name] = filters unless filters.blank?
    end
  end

end
