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

module OpportunitiesHelper

  # Sidebar checkbox control for filtering opportunities by stage.
  #----------------------------------------------------------------------------
  def opportunity_stage_checbox(stage, count)
    checked = (session[:filter_by_opportunity_stage] ? session[:filter_by_opportunity_stage].split(",").include?(stage.to_s) : count.to_i > 0)
    check_box_tag("stage[]", stage, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"stage=" + $$("input[name='stage[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
