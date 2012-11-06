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

module EventInstancesHelper

  
  #----------------------------------------------------------------------------
  def link_to_event_instance_mark(contact, event_instance)
    onclick = %Q/$("#{dom_id(contact, :mark)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => mark_event_instance_path(event_instance), :method => :put, :with => "'contact_id=#{contact.id}'")
  end

  #----------------------------------------------------------------------------
  def link_to_event_instance_unmark(contact, event_instance)
    onclick = %Q/$("#{dom_id(contact, :mark)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => unmark_event_instance_path(event_instance), :method => :put, :with => "'contact_id=#{contact.id}'")
  end

  def attendance_section(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    select_id  = "select_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = tag(:br)
    html << content_tag(:div, link_to(t(select_id), "#", :id => select_id), :class => "subtitle_tools")
    html << content_tag(:div, "&nbsp;|&nbsp;".html_safe, :class => "subtitle_tools")
    html << content_tag(:div, link_to_inline(create_id, create_url, :text => t(create_id), :event_instance_id => @event_instance.id), :class => "subtitle_tools")
    html << content_tag(:div, "Attendees", :class => :subtitle, :id => "create_#{asset}_title")
    html << content_tag(:div, "", :class => :remote, :id => create_id, :style => "display:none;")
  end

  #----------------------------------------------------------------------------
  def hide_task_and_possibly_bucket(id, bucket)
    update_page do |page|
      page[id].replace ""

      if Task.bucket_empty?(bucket, current_user, @view)
        page["list_#{bucket}"].visual_effect :fade, :duration => 0.5
      end
    end
  end

  #----------------------------------------------------------------------------
  def replace_content(task, bucket = nil)
    partial = (task.assigned_to && task.assigned_to != current_user.id) ? "assigned" : "pending"
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
      if @view == "pending" && @task.assigned_to != current_user.id
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
