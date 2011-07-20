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

module TasksHelper

  # Sidebar checkbox control for filtering tasks by due date -- used for
  # pending and assigned views only.
  #----------------------------------------------------------------------------
  def task_filter_checbox(view, filter, count)
    name = "filter_by_task_#{view}"
    checked = (session[name] ? session[name].split(",").include?(filter.to_s) : count > 0)
    onclick = remote_function(
      :url      => { :action => :filter, :view => view },
      :with     => "'filter='+this.value+'&checked='+this.checked",
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    check_box_tag("filters[]", filter, checked, :onclick => onclick)
  end

  #----------------------------------------------------------------------------
  def filtered_out?(view, filter = nil)
    name = "filter_by_task_#{view}"
    if filter
      filters = (session[name].nil? ? [] : session[name].split(","))
      !filters.include?(filter.to_s)
    else
      session[name].blank?
    end
  end

  #----------------------------------------------------------------------------
  def link_to_task_edit(task, bucket)
    link_to(t(:edit), edit_task_path(task),
      :method => :get,
      :with   => "{ bucket: '#{bucket}', view: '#{@view}', previous: crm.find_form('edit_task') }",
      :remote => true
    )
  end

  #----------------------------------------------------------------------------
  def link_to_task_delete(task, bucket)
    link_to(t(:delete) + "!", task_path(task),
      :method => :delete,
      :with   => "{ bucket: '#{bucket}', view: '#{@view}' }",
      :before => visual_effect(:highlight, dom_id(task), :startcolor => "#ffe4e1"),
      :remote => true
    )
  end

  #----------------------------------------------------------------------------
  def link_to_task_complete(pending, bucket)
    onclick = %Q/$("#{dom_id(pending, :name)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => complete_task_path(pending), :method => :put, :with => "'bucket=#{bucket}'")
  end

  # Helper to display XLS, CSV, RSS, and ATOM links for tasks.
  #----------------------------------------------------------------------------
  def links_to_task_export(view)
    token = @current_user.single_access_token

    exports = %w(xls csv).map do |format|
      link_to(format.upcase, "#{tasks_path}.#{format}?view=#{view}", :title => I18n.t(:"to_#{format}"))
    end
    feeds = %w(rss atom).map do |format|
      link_to(format.upcase, "#{tasks_path}.#{format}?view=#{view}&authentication_credentials=#{token}", :title => I18n.t(:"to_#{format}"))
    end

    (exports + feeds).join(' | ')
  end

  # Task summary for RSS/ATOM feed.
  #----------------------------------------------------------------------------
  def task_summary(task)
    summary = [ task.category.blank? ? t(:other) : t(task.category) ]
    if @view != "completed"
      if @view == "pending" && task.user != @current_user
        summary << t(:task_from, task.user.full_name)
      elsif @view == "assigned"
        summary << t(:task_from, task.assignee.full_name)
      end
      summary << "#{t(:related)} #{task.asset.name} (#{task.asset_type.downcase})" if task.asset_id?
      summary << if task.bucket == "due_asap"
        t(:task_due_now)
      elsif task.bucket == "due_later"
        t(:task_due_later)
      else
        l(task.due_at.localtime, :format => :mmddhhss)
      end
    else # completed
      summary << "#{t(:related)} #{task.asset.name} (#{task.asset_type.downcase})" if task.asset_id?
      summary << t(:task_completed_by,
                   :time_ago => distance_of_time_in_words(task.completed_at, Time.now),
                   :date     => l(task.completed_at.localtime, :format => :mmddhhss),
                   :user     => task.completor.full_name)
    end
    summary.join(', ')
  end

  #----------------------------------------------------------------------------
  def hide_task_and_possibly_bucket(id, bucket)
    update_page do |page|
      page[id].replace ""

      if Task.bucket_empty?(bucket, @current_user, @view)
        page["list_#{bucket}"].visual_effect :fade, :duration => 0.5
      end
    end
  end

  #----------------------------------------------------------------------------
  def replace_content(task, bucket = nil)
    partial = (task.assigned_to && task.assigned_to != @current_user.id) ? "assigned" : "pending"
    update_page do |page|
      page[dom_id(task)].replace_html :partial => "tasks/#{partial}", :collection => [ task ], :locals => { :bucket => bucket }
    end
  end

  #----------------------------------------------------------------------------
  def insert_content(task, bucket, view)
    update_page do |page|
      page["list_#{bucket}"].show
      page.insert_html :top, bucket, :partial => view, :collection => [ task ], :locals => { :bucket => bucket }
      page[dom_id(task)].visual_effect :highlight, :duration => 1.5
    end
  end

  #----------------------------------------------------------------------------
  def tasks_flash(message)
    update_page do |page|
      page[:flash].replace_html message
      page.call "crm.flash", :notice, true
    end
  end

  #----------------------------------------------------------------------------
  def reassign(id)
    update_page do |page|
      if @view == "pending" && @task.assigned_to != @current_user.id
        page << hide_task_and_possibly_bucket(id, @task_before_update.bucket)
        page << tasks_flash("#{t(:task_assigned, @task.assignee.full_name)} (" << link_to(t(:view_assigned_tasks), url_for(:controller => :tasks, :view => :assigned)) << ").")
      elsif @view == "assigned" && @task.assigned_to.blank?
        page << hide_task_and_possibly_bucket(id, @task_before_update.bucket)
        page << tasks_flash("#{t(:task_pending)} (" << link_to(t(:view_pending_tasks), tasks_url) << ").")
      else
        page << replace_content(@task, @task.bucket)
      end
      page << refresh_sidebar(:index, :filters)
    end
  end

  #----------------------------------------------------------------------------
  def reschedule(id)
    update_page do |page|
      page << hide_task_and_possibly_bucket(id, @task_before_update.bucket)
      page << insert_content(@task, @task.bucket, @view)
      page << refresh_sidebar(:index, :filters)
    end
  end

end
