# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module TasksHelper

  # Sidebar checkbox control for filtering tasks by due date -- used for
  # pending and assigned views only.
  #----------------------------------------------------------------------------
  def task_filter_checkbox(view, filter, count)
    name = "filter_by_task_#{view}"
    checked = (session[name] ? session[name].split(",").include?(filter.to_s) : count > 0)
    url = url_for(:action => :filter, :view => view)
    onclick = %Q{
      $('#loading').show();
      $.post('#{url}', {filter: this.value, checked: this.checked}, function () {
        $('#loading').hide();
      });
    }
    check_box_tag("filters[]", filter, checked, :onclick => onclick, :id => "filters_#{filter.to_s.underscore}")
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
    link_to(t(:edit), edit_task_path(task, :bucket => bucket, :view => @view, :previous => "crm.find_form('edit_task')"),
      :method => :get, :remote => true)
  end

  #----------------------------------------------------------------------------
  def link_to_task_delete(task, bucket)
    link_to(t(:delete) + "!", task_path(task, :bucket => bucket, :view => @view),
      :method => :delete, :remote => true)
  end

  #----------------------------------------------------------------------------
  def link_to_task_complete(pending, bucket)
    onclick = %Q{$("##{dom_id(pending, :name)}").css({textDecoration: "line-through"});}
    onclick << %Q{$.ajax("#{complete_task_path(pending)}", {type: "PUT", data: {bucket: "#{bucket}"}});}
  end

  # Task summary for RSS/ATOM feed.
  #----------------------------------------------------------------------------
  def task_summary(task)
    summary = [ task.category.blank? ? t(:other) : t(task.category) ]
    if @view != "completed"
      if @view == "pending" && task.user != current_user
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
  def hide_task_and_possibly_bucket(task, bucket)
    text = "$('##{dom_id(task)}').remove();\n"
    text << "$('#list_#{h bucket.to_s}').fadeOut({ duration:500 });\n" if Task.bucket_empty?(bucket, current_user, @view)
    text.html_safe
  end

  #----------------------------------------------------------------------------
  def replace_content(task, bucket = nil)
    partial = (task.assigned_to && task.assigned_to != current_user.id) ? "assigned" : "pending"
    html = render(:partial => "tasks/#{partial}", :collection => [ task ], :locals => { :bucket => bucket })
    text = "$('##{dom_id(task)}').html('#{ j html }');\n".html_safe
  end

  #----------------------------------------------------------------------------
  def insert_content(task, bucket, view)
    text = "$('#list_#{bucket}').show();\n".html_safe
    html = render(:partial => view, :collection => [ task ], :locals => { :bucket => bucket })
    text << "$('##{h bucket.to_s}').prepend('#{ j html }');\n".html_safe
    text << "$('##{dom_id(task)}').effect('highlight', { duration:1500 });\n".html_safe
    text
  end

  #----------------------------------------------------------------------------
  def tasks_flash(message)
    text = "$('#flash').html('#{ message }');\n"
    text << "crm.flash('notice', true)\n"
    text.html_safe
  end

  #----------------------------------------------------------------------------
  def reassign(task)
    text = "".html_safe
    if @view == "pending" && @task.assigned_to.present? && @task.assigned_to != current_user.id
      text << hide_task_and_possibly_bucket(task, @task_before_update.bucket)
      text << tasks_flash( t(:task_assigned, (h @task.assignee.try(:full_name))) + " (#{link_to(t(:view_assigned_tasks), url_for(:controller => :tasks, :view => :assigned))})" )
    elsif @view == "assigned" && @task.assigned_to.blank?
      text << hide_task_and_possibly_bucket(task, @task_before_update.bucket)
      text << tasks_flash( t(:task_pending) + " (#{link_to(t(:view_pending_tasks), tasks_url)}.")
    else
      text << replace_content(@task, @task.bucket)
    end
    text << refresh_sidebar(:index, :filters)
    text
  end

  #----------------------------------------------------------------------------
  def reschedule(task)
    text = hide_task_and_possibly_bucket(task, @task_before_update.bucket)
    text << insert_content(task, task.bucket, @view)
    text << refresh_sidebar(:index, :filters)
    text
  end

end
