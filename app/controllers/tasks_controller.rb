class TasksController < ApplicationController
  before_filter :require_user
  before_filter :update_sidebar, :only => :index
  before_filter "set_current_tab(:tasks)", :only => [ :index, :show ]

  # GET /tasks
  # GET /tasks.xml
  #----------------------------------------------------------------------------
  def index
    @tasks = Task.find_all_grouped(@current_user, @view)

    respond_to do |format|
      format.html # index.html.haml
      # Hash keys must be strings... symbols generate "undefined method 'singularize' error"
      format.xml  { render :xml => @tasks.inject({}) { |tasks, (k,v)| tasks[k.to_s] = v; tasks } }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  #----------------------------------------------------------------------------
  def show
    respond_to do |format|
      format.html { render :action => :index }
      format.xml  { @task = Task.find(params[:id]);  render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def new
    @view = params[:view] || "pending"
    @task = Task.new
    @users = User.all_except(@current_user)
    @due_at_hint = Setting.task_due_at_hint[1..-1] << [ "On Specific Date...", :specific_time ]
    @category = Setting.invert(:task_category)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@asset", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @task = Task.find(params[:id])
    @view = params[:view] || "pending"
    @users = User.all_except(@current_user)
    @due_at_hint = Setting.task_due_at_hint[1..-1] << [ "On Specific Date...", :specific_time ]
    @category = Setting.invert(:task_category)
    @asset = @task.asset if @task.asset_id?
    if params[:previous] =~ /(\d+)\z/
      @previous = Task.find($1)
    end
  end

  # POST /tasks
  # POST /tasks.xml                                                        AJAX
  #----------------------------------------------------------------------------
  def create
    @task = Task.new(params[:task]) # NOTE: we don't display validation messages for tasks.
    @view = params[:view] || "pending"

    respond_to do |format|
      if @task.save
        update_sidebar if request.referer =~ /\/tasks\?*/
        format.js   # create.js.rjs
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  def update
    @task = Task.find(params[:id])
    @view = params[:view] || "pending"

    respond_to do |format|
      if @task.update_attributes(params[:task])
        update_sidebar if request.referer =~ /\/tasks\?*/
        format.js
        format.xml  { head :ok }
      else
        format.js
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    @view = params[:view] || "pending"

    # Make sure bucket's div gets hidden if we're deleting last task in the bucket.
    @bucket = Task.bucket(@current_user, params[:bucket], @view)

    update_sidebar if request.referer =~ /\/tasks\?*/ && !params[:bucket].blank?
    respond_to do |format|
      format.js
      format.xml  { head :ok }
    end
  end

  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml                                              AJAX
  #----------------------------------------------------------------------------
  def complete
    @task = Task.find(params[:id])
    @task.update_attributes(:completed_at => Time.now)

    # Make sure bucket's div gets hidden if it's the last completed task in the bucket.
    @bucket = Task.bucket(@current_user, params[:bucket])

    update_sidebar unless params[:bucket].blank?
    respond_to do |format|
      format.js   # complete.js.rjs
      format.xml  { head :ok }
    end
  end

  # Ajax request to filter out a list of tasks.                            AJAX
  #----------------------------------------------------------------------------
  def filter
    @view = params[:view] || "pending"

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
