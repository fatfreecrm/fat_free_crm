class TasksController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter "set_current_tab(:tasks)"

  # GET /tasks
  # GET /tasks.xml
  #----------------------------------------------------------------------------
  def index
    @task = Task.new
    if @view == "pending"
      @tasks = Setting.task_due_date.inject({}) { |hash, (value, key)| hash[key] = Task.my(@current_user).send(key).pending; hash }
    elsif @view == "assigned"
      @tasks = Setting.task_due_date.inject({}) { |hash, (value, key)| hash[key] = Task.assigned_by(@current_user).send(key).pending; hash }
    else # @view == "completed"
      @tasks = Setting.task_completed.inject({}) { |hash, (value, key)| hash[key] = Task.my(@current_user).send(key).completed; hash }
    end
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
    session["tasks_new_#{@view}".intern] = (params[:visible] == "false" ? true : nil)

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
    @view = params[:view]
    @view = "pending" unless %w(pending assigned).include?(@view)
    @tasks = {}

    name = "filter_by_task_#{@view}".intern
    old_filters = (session[name].nil? ? [] : session[name].split(","))
    new_filters = params[:due_date].split(",")
    if new_filters.size > old_filters.size                      # Checked => Show
      filter = (new_filters - old_filters).first.intern
      if @view == "pending"
        @tasks[filter] = Task.my(@current_user).send(filter).pending
      else
        @tasks[filter] = Task.assigned_by(@current_user).send(filter).pending
      end
    else                                                        # Unchecked => Hide
      filter = (old_filters - new_filters).first.intern
      @tasks[filter] = []
    end
    session[name] = params[:due_date]
    @category = Setting.task_category.invert.sort
    
    render :update do |page|
      Setting.task_due_date.each do |value, key|
        next if key != filter
        page["list_#{filter}"].replace_html render(:partial => "list", :locals => { :key => key, :value => value })
      end
    end
  end

  private

  # Dispatch to appropriate sidebar handler, then save filters with non-zero
  # task counts in a session.
  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @view = params[:view]
    @view = "pending" unless %w(pending assigned completed).include?(@view)
    send("sidebar_for_#{@view}")

    name = "filter_by_task_#{@view}".intern
    unless session[name]
      filters = @task_total.keys.select { |key| key != :all && @task_total[key] != 0 }.join(",")
      session[name] = (filters.blank? ? nil : filters)
    end
  end

  #----------------------------------------------------------------------------
  def sidebar_for_pending
    @task_total = { :all => 0 }
    Setting.task_due_date.each do |value, key|
      @task_total[:all] += @task_total[key] = Task.my(@current_user).send(key).pending.count
    end
  end

  #----------------------------------------------------------------------------
  def sidebar_for_assigned
    @task_total = { :all => 0 }
    Setting.task_due_date.each do |value, key|
      @task_total[:all] += @task_total[key] = Task.assigned_by(@current_user).send(key).pending.count
    end
  end

  #----------------------------------------------------------------------------
  def sidebar_for_completed
    @task_total = { :all => 0 }
    Setting.task_completed.each do |value, key|
      @task_total[:all] += @task_total[key] = Task.my(@current_user).send(key).completed.count
    end
  end

end
