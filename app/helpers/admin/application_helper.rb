# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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

module Admin::ApplicationHelper

  def tabs
    super(FatFreeCRM::Tabs.admin)
  end

  #----------------------------------------------------------------------------
  def link_to_edit(model)
    name = model.class.name.underscore.gsub('/','_')

    link_to_remote(t(:edit),
      :method => :get,
      :url    => send("edit_admin_#{name}_path", model),
      :with   => "{ previous: crm.find_form('edit_admin_#{name}') }"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_delete(model)
    name = model.class.name.underscore.gsub('/','_')

    link_to_remote(t(:delete) + "!",
      :method => :delete,
      :url    => send("admin_#{name}_path", model),
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def confirm_delete(model)
    question = %(<span class="warn">#{t(:confirm_delete, model.class.to_s.downcase)}</span>)
    yes = link_to(t(:yes_button), [:admin, model], :method => :delete)
    no = link_to_function(t(:no_button), "$('menu').update($('confirm').innerHTML)")
    update_page do |page|
      page << "$('confirm').update($('menu').innerHTML)"
      page[:menu].replace_html "#{question} #{yes} : #{no}"
    end
  end

end
