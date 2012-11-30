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

module EventsHelper

  #----------------------------------------------------------------------------
  def link_to_mark(contact, event)
    #onclick = %Q/$("#{dom_id(contact, :mark)}").style.textDecoration="line-through";/
    onclick = remote_function(:url => mark_event_instance_path(event), :method => :put, :with => "'contact_id=#{contact.id}'")
  end

  #----------------------------------------------------------------------------
  def link_to_unmark(contact, event)
    #onclick = %Q/$("#{dom_id(contact, :mark)}").style.textDecoration="line-through";/
    onclick = remote_function(:url => unmark_event_instance_path(event), :method => :put, :with => "'contact_id=#{contact.id}'")
  end

  def attendance_section(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    select_id  = "select_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = tag(:br)
    html << content_tag(:div, link_to(t(select_id), "#", :id => select_id), :class => "subtitle_tools")
    html << content_tag(:div, "&nbsp;|&nbsp;".html_safe, :class => "subtitle_tools")
    html << content_tag(:div, link_to_inline(create_id, create_url, :related => (related ? dom_id(related) : nil), :text => t(create_id), :event_instance_id => @event_instance.id), :class => "subtitle_tools")
    html << content_tag(:div, "Attendees", :class => :subtitle, :id => "create_#{asset}_title")
    html << content_tag(:div, "", :class => :remote, :id => create_id, :style => "display:none;")
  end


  # Sidebar checkbox control for filtering accounts by category.
  #----------------------------------------------------------------------------
  def event_category_checbox(category, count)
    checked = (session[:events_filter] ? session[:events_filter].split(",").include?(category.to_s) : count.to_i > 0)
    onclick = remote_function(
      :url      => { :action => :filter },
      :with     => h(%Q/"category=" + $$("input[name='category[]']").findAll(function (el) { return el.checked }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    check_box_tag("category[]", category, checked, :id => category, :onclick => onclick)
  end

  # Quick account summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def event_summary(account)
    [ number_to_currency(account.opportunities.pipeline.map(&:weighted_amount).sum, :precision => 0),
      t(:added_by, :time_ago => time_ago_in_words(account.created_at), :user => account.user_id_full_name),
      t('pluralize.contact', account.contacts.count),
      t('pluralize.opportunity', account.opportunities.count),
      t('pluralize.comment', account.comments.count)
    ].join(', ')
  end
  
  def event_select(options = {})
      # Generates a select list with the first 25 accounts,
      # and prepends the currently selected account, if available
      options[:selected] = (@event && @event.id) || 0
      events = ([@event] + Event.my.order(:name).limit(25)).compact.uniq
      collection_select :event, :id, events, :id, :name, options,
                        {:"data-placeholder" => t(:select_a_event),
                         :style => "width:330px; display:none;" }
  end
  
end
