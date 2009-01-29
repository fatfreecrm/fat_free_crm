class TasksController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:tasks)"

  # GET /tasks
  # GET /tasks.xml
  #----------------------------------------------------------------------------
  def index
    @task = Task.new
    if @view == "completed"
      @tasks = Task.completed
    elsif @view == "assigned"
      @tasks = Setting.task_due_date.inject({}) { |hash, (value, key)| hash[key] = Task.send(key).assigned; hash }
    else
      @tasks = Setting.task_due_date.inject({}) { |hash, (value, key)| hash[key] = Task.send(key); hash }
    end
    @due_date = Setting.task_due_date[1..-1] << [ "On specific date...", :on_specific_date ]
    @category = Setting.task_category.invert.sort

    respond_to do |format|
      format.html # index.html.erb
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
    @task = Task.new
    @users = User.all_except(@current_user) # to assign the task
    session[:tasks_new] = (params[:visible] == "false" ? true : nil)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
      format.js   # new.js.rjs
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

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
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

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end

  # Ajax request to filter out list of tasks.
  #----------------------------------------------------------------------------
  def filter
    @tasks = {}
    @category = Setting.task_category.invert.sort

    old_filters = (session[:filter_by_task_due_date].nil? ? [] : session[:filter_by_task_due_date].split(","))
    new_filters = params[:due_date].split(",")
    if new_filters.size > old_filters.size # checked: show
      filter = (new_filters - old_filters).first.intern
      @tasks[filter] = Task.send(filter)
    else # unchecked: hide
      filter = (old_filters - new_filters).first.intern
      @tasks[filter] = []
    end
    session[:filter_by_task_due_date] = params[:due_date]
    
    render :update do |page|
      Setting.task_due_date.each do |value, key|
        next if key != filter
        page["list_#{filter}"].replace_html render(:partial => "list", :locals => { :key => key, :value => value })
      end
    end
  end

  private
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @view = params[:view] || "pending"
    @task_due_date_total = { :all => Task.pending.count, :other => 0 }
    Setting.task_due_date.each do |value, key|
      @task_due_date_total[key] = Task.send(key).count
    end
  end

end
