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

class AjaxWillPaginate < WillPaginate::LinkRenderer

  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

  protected
  # "Ajaxify" page links by using :link_to_remote instead of :link_to. Also 
  # remove action part from the url, so it always points to :index and looks
  # like /controller?page=N
  #----------------------------------------------------------------------------
  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, { 
      :url     => url_for(page).sub(/(#{Setting.base_url}\/\w+)\/[^\?]+\?/, "\\1?"),
      :method  => :get,
      :loading => "$('paging').show()",
      :success => "$('paging').hide()"
    }.merge(@remote))
  end

end
