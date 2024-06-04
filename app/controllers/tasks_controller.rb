# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class TasksController < ApplicationController
  before_action :set_current_tab, only: %i[index show]
  before_action :update_sidebar, only: :index

  # GET /tasks
  #----------------------------------------------------------------------------
  def index
    @view = view
    @tasks = Task.find_all_grouped(current_user, @view)

    respond_with @tasks do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @tasks.map(&:second).flatten }
      format.xml { render xml: @tasks, except: [:subscribed_users] }
    end
  end

  # GET /tasks/1
  #----------------------------------------------------------------------------
  def show
    @task = Task.tracked_by(current_user).find(params[:id])
    respond_with(@task)
  end

  # GET /tasks/new
  #----------------------------------------------------------------------------
  def new
    @view = view
    @task = Task.new
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [t(:due_specific_date, default: 'On Specific Date...'), :specific_time]
    @category = Setting.unroll(:task_category)

    if params[:related]
      model, id = params[:related].split(/_(\d+)/)
      if related = model.classify.constantize.my(current_user).find_by_id(id)
        instance_variable_set("@asset", related)
      else
        respond_to_related_not_found(model) && return
      end
    end

    respond_with(@task)
  end

  # GET /tasks/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @view = view
    @task = Task.tracked_by(current_user).find(params[:id])
    @bucket = Setting.unroll(:task_bucket)[1..-1] << [t(:due_specific_date, default: 'On Specific Date...'), :specific_time]
    @category = Setting.unroll(:task_category)
    @asset = @task.asset if @task.asset_id?

    @previous = Task.tracked_by(current_user).find_by_id(detect_previous_id) || detect_previous_id if detect_previous_id

    respond_with(@task)
  end

  # POST /tasks
  #----------------------------------------------------------------------------
  def create
    @view = view
    @task = Task.new(task_params) # NOTE: we don't display validation messages for tasks.

    respond_with(@task) do |_format|
      if @task.save
        update_sidebar if called_from_index_page?
      end
    end
  end

  # PUT /tasks/1
  #----------------------------------------------------------------------------
  def update
    @view = view
    @task = Task.tracked_by(current_user).find(params[:id])
    @task_before_update = @task.dup

    @task_before_update.bucket = if @task.due_at && (@task.due_at < Date.today.to_time)
                                   "overdue"
                                 else
                                   @task.computed_bucket
                                 end

    respond_with(@task) do |_format|
      if @task.update(task_params)
        @task.bucket = @task.computed_bucket
        if called_from_index_page?
          @empty_bucket = @task_before_update.bucket if Task.bucket_empty?(@task_before_update.bucket, current_user, @view)
          update_sidebar
        end
      end
    end
  end

  # DELETE /tasks/1
  #----------------------------------------------------------------------------
  def destroy
    @view = view
    @task = Task.tracked_by(current_user).find(params[:id])
    @task.destroy

    # Make sure bucket's div gets hidden if we're deleting last task in the bucket.
    @empty_bucket = params[:bucket] if Task.bucket_empty?(params[:bucket], current_user, @view)

    update_sidebar if called_from_index_page?
    respond_with(@task)
  end

  # PUT /tasks/1/complete
  #----------------------------------------------------------------------------
  def complete
    @task = Task.tracked_by(current_user).find(params[:id])
    @task&.update(completed_at: Time.now, completed_by: current_user.id)

    # Make sure bucket's div gets hidden if it's the last completed task in the bucket.
    @empty_bucket = params[:bucket] if Task.bucket_empty?(params[:bucket], current_user)

    update_sidebar unless params[:bucket].blank?
    respond_with(@task)
  end

  # PUT /tasks/1/uncomplete
  #----------------------------------------------------------------------------
  def uncomplete
    @task = Task.tracked_by(current_user).find(params[:id])
    @task&.update(completed_at: nil, completed_by: nil)

    # Make sure bucket's div gets hidden if we're deleting last task in the bucket.
    @empty_bucket = params[:bucket] if Task.bucket_empty?(params[:bucket], current_user, @view)

    update_sidebar
    respond_with(@task)
  end

  # POST /tasks/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # Ajax request to filter out a list of tasks.                            AJAX
  #----------------------------------------------------------------------------
  def filter
    @view = view

    update_session do |filters|
      if params[:checked].true?
        filters << params[:filter]
      else
        filters.delete(params[:filter])
      end
    end
  end

  protected

  def task_params
    return {} unless params[:task]

    params.require(:task).permit(
      :user_id,
      :assigned_to,
      :completed_by,
      :name,
      :asset_id,
      :asset_type,
      :priority,
      :category,
      :bucket,
      :due_at,
      :completed_at,
      :deleted_at,
      :background_info,
      :calendar
    )
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
    @view = view
    @task_total = Task.totals(current_user, @view)

    # Update filters session if we added, deleted, or completed a task.
    if @task
      update_session do |filters|
        if @empty_bucket # deleted, completed, rescheduled, or reassigned and need to hide a bucket
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

  # Ensure view is allowed
  #----------------------------------------------------------------------------
  def view
    view = params[:view]
    views = Task::ALLOWED_VIEWS
    views.include?(view) ? view : views.first
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_tasks_controller, self)
end
