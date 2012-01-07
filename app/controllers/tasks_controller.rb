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

class TasksController < BaseController
  before_filter :auto_complete, :only => :auto_complete
  before_filter :update_sidebar, :only => :index
  skip_after_filter :update_recently_viewed

  # GET /tasks
  #----------------------------------------------------------------------------
  def index
    @view = params[:view] || "pending"
    @tasks = Task.find_all_grouped(@current_user, @view)
    respond_with(@tasks)
  end

  # GET /tasks/1
  #----------------------------------------------------------------------------
  def show
    respond_to do |format|
      format.html { render :index }
      format.json { @task = Task.tracked_by(@current_user).find(params[:id]);  render :json => @task }
      format.xml  { @task = Task.tracked_by(@current_user).find(params[:id]);  render :xml => @task }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # GET /tasks/new
  #----------------------------------------------------------------------------
  def new
    @view = params[:view] || "pending"
    @task = Task.new
    @users = User.except(@current_user).by_name
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [ t(:due_specific_date, :default => 'On Specific Date...'), :specific_time ]
    @category = Setting.unroll(:task_category)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@asset", model.classify.constantize.my.find(id))
    end
    respond_with(@task)

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /tasks/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @view = params[:view] || "pending"
    @task = Task.tracked_by(@current_user).find(params[:id])
    @users = User.except(@current_user).by_name
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [ t(:due_specific_date, :default => 'On Specific Date...'), :specific_time ]
    @category = Setting.unroll(:task_category)
    @asset = @task.asset if @task.asset_id?
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Task.tracked_by(@current_user).find($1)
    end
    respond_with(@task)

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @task
  end

  # POST /tasks
  #----------------------------------------------------------------------------
  def create
    @view = params[:view] || "pending"
    @task = Task.new(params[:task]) # NOTE: we don't display validation messages for tasks.

    respond_with(@task) do |format|
      if @task.save
        update_sidebar if called_from_index_page?
      end
    end
  end

  # PUT /tasks/1
  #----------------------------------------------------------------------------
  def update
    @view = params[:view] || "pending"
    @task = Task.tracked_by(@current_user).find(params[:id])
    @task_before_update = @task.clone

    if @task.due_at && (@task.due_at < Date.today.to_time)
      @task_before_update.bucket = "overdue"
    else
      @task_before_update.bucket = @task.computed_bucket
    end

    respond_with(@task) do |format|
      if @task.update_attributes(params[:task])
        @task.bucket = @task.computed_bucket
        if called_from_index_page?
          if Task.bucket_empty?(@task_before_update.bucket, @current_user, @view)
            @empty_bucket = @task_before_update.bucket
          end
          update_sidebar
        end
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /tasks/1
  #----------------------------------------------------------------------------
  def destroy
    @view = params[:view] || "pending"
    @task = Task.tracked_by(@current_user).find(params[:id])
    @task.destroy if @task

    # Make sure bucket's div gets hidden if we're deleting last task in the bucket.
    if Task.bucket_empty?(params[:bucket], @current_user, @view)
      @empty_bucket = params[:bucket]
    end

    update_sidebar if called_from_index_page?
    respond_with(@task)

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # PUT /tasks/1/complete
  #----------------------------------------------------------------------------
  def complete
    @task = Task.tracked_by(@current_user).find(params[:id])
    @task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id) if @task

    # Make sure bucket's div gets hidden if it's the last completed task in the bucket.
    if Task.bucket_empty?(params[:bucket], @current_user)
      @empty_bucket = params[:bucket]
    end

    update_sidebar unless params[:bucket].blank?
    respond_with(@task)

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # POST /tasks/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete

  # Ajax request to filter out a list of tasks.                            AJAX
  #----------------------------------------------------------------------------
  def filter
    @view = params[:view] || "pending"

    update_session do |filters|
      if params[:checked].true?
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
        if @empty_bucket  # deleted, completed, rescheduled, or reassigned and need to hide a bucket
          filters.delete(@empty_bucket)
        elsif !@task.deleted_at && !@task.completed_at # created new task
          filters << @task.computed_bucket
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
