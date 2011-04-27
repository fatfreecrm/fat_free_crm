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
    filtering_checkbox(Opportunity, 'stage', stage, (count.to_i > 0), :id => stage)
  end

  # Sidebar checkbox control for filtering opportunities by tag.
  #----------------------------------------------------------------------------
  def opportunity_tag_checkbox(tagg)
    filtering_checkbox(Opportunity, 'tags', tagg.name, false, :id => "tag-#{tagg.id}")
  end

end
