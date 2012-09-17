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

module CampaignsHelper

  # Sidebar checkbox control for filtering campaigns by status.
  #----------------------------------------------------------------------------
  def campaign_status_checkbox(status, count)
    entity_filter_checkbox(:status, status, count)
  end

  #----------------------------------------------------------------------------
  def performance(actual, target)
    if target.to_i > 0 && actual.to_i > 0
      if target > actual
        n = 100 - actual * 100 / target
        html = content_tag(:span, "(-#{number_to_percentage(n, :precision => 1)})", :class => "warn")
      else
        n = actual * 100 / target - 100
        html = content_tag(:span, "(+#{number_to_percentage(n, :precision => 1)})", :class => "cool")
      end
    end
    html || ""
  end

  # Quick campaign summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def campaign_summary(campaign)
    status  = render :file => "campaigns/_status.html.haml",  :locals => { :campaign => campaign }
    metrics = render :file => "campaigns/_metrics.html.haml", :locals => { :campaign => campaign }
    "#{t(campaign.status)}, " << [ status, metrics ].map { |str| strip_tags(str) }.join(' ').gsub("\n", '')
  end
end

