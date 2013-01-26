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

module ContactsHelper
  
  # Sidebar checkbox control for filtering contacts by folder.
  #----------------------------------------------------------------------------
  def contact_folder_checbox(folder, count)
    id = (folder == "other") ? "other" : folder.id
    checked = (session[:contacts_filter] ? session[:contacts_filter].split(",").include?(id.to_s) : count.to_i > 0)
    onclick = remote_function(
      :url      => { :controller => :contacts, :action => :filter },
      :with     => h(%Q/"folder=" + $$("input[name='folder[]']").findAll(function (el) { return el.checked }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    
    check_box_tag("folder[]", id, checked, :id => id, :onclick => onclick)
  end
  
  # Sidebar checkbox control for filtering contacts by folder.
  #----------------------------------------------------------------------------
  def user_contact_checbox(user, count)
    id = (user == "other") ? "other" : user.id
    checked = (session[:contacts_user_filter] ? session[:contacts_user_filter].split(",").include?(id.to_s) : count.to_i > 0)
    onclick = remote_function(
      :url      => { :controller => :contacts, :action => :filter },
      :with     => h(%Q/"user=" + $$("input[name='user[]']").findAll(function (el) { return el.checked }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    
    check_box_tag("user[]", id, checked, :id => id, :onclick => onclick)
  end
  
  def label_folder_select(folder, text)
    ids = folder.class == Account ? [folder.id.to_s] : [folder.to_s]
    contact_folder_checbox_select(text, ids)
  end
  
  def label_user_select(user, text)
    ids = user.class == User ? [user.id.to_s] : [user.to_s]
    contact_user_checbox_select(text, ids)
  end
  
  def contact_user_checbox_select(text, ids = [])
    onclick = remote_function(
      :url      => { :controller => :contacts, :action => :filter },
      :with     => h(%Q/"user=" + $$("input[name='user[]']").findAll(function (el) { el.checked = ((#{ids}.indexOf(el.value) >= 0) ? true : false); return el.checked; }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    
    link_to(text, "#", :remote => true, :onclick => onclick)
  end
  
  
  def contact_folder_checbox_select(text, ids = [])
    onclick = remote_function(
      :url      => { :controller => :contacts, :action => :filter },
      :with     => h(%Q/"folder=" + $$("input[name='folder[]']").findAll(function (el) { el.checked = ((#{ids}.indexOf(el.value) >= 0) ? true : false); return el.checked; }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    
    link_to(text, "#", :remote => true, :onclick => onclick)
  end
  
  #----------------------------------------------------------------------------
  def link_to_graduate(record, options = {})
    object = record.is_a?(Array) ? record.last : record
    confirm = options[:confirm] || nil

    link_to("Graduate",
      options[:url] || graduate_contact_path(record),
      :method => :post,
      :remote => true,
      #:onclick => visual_effect(:highlight, dom_id(object), :startcolor => "#ffe4e1"),
      :confirm => confirm
    )
  end
  
  #----------------------------------------------------------------------------
  def link_to_confirm(contact)
    link_to(t(:delete) + "?", confirm_contact_path(contact), :method => :get, :remote => true)
  end
  
  # Contact summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def contact_summary(contact)
    summary = [""]
    summary << contact.title.titleize if contact.title?
    summary << contact.department if contact.department?
    if contact.account && contact.account.name?
      summary.last << " #{t(:at)} #{contact.account.name}"
    end
    summary << contact.email if contact.email.present?
    summary << "#{t(:phone_small)}: #{contact.phone}" if contact.phone.present?
    summary << "#{t(:mobile_small)}: #{contact.mobile}" if contact.mobile.present?
    summary.join(', ')
  end
end

