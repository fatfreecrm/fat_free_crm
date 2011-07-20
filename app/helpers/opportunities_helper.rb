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

module OpportunitiesHelper

  # Sidebar checkbox control for filtering opportunities by stage.
  #----------------------------------------------------------------------------
  def opportunity_stage_checbox(stage, count)
    checked = (session[:filter_by_opportunity_stage] ? session[:filter_by_opportunity_stage].split(",").include?(stage.to_s) : count.to_i > 0)
    onclick = remote_function(
      :url      => { :action => :filter },
      :with     => h(%Q/"stage=" + $$("input[name='stage[]']").findAll(function (el) { return el.checked }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    check_box_tag("stage[]", stage, checked, :id => stage, :onclick => onclick)
  end

  # Opportunity summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def opportunity_summary(opportunity)
    summary, amount = [], []
    summary << (opportunity.stage ? t(opportunity.stage) : t(:other))
    summary << number_to_currency(opportunity.weighted_amount, :precision => 0)
    unless %w(won lost).include?(opportunity.stage)
      amount << number_to_currency(opportunity.amount || 0, :precision => 0)
      amount << (opportunity.discount ? t(:discount_number, number_to_currency(opportunity.discount, :precision => 0)) : t(:no_discount))
      amount << t(:probability_number, (opportunity.probability || 0).to_s + '%')
      summary << amount.join(' ')
    end
    if opportunity.closes_on
      summary << t(:closing_date, l(opportunity.closes_on, :format => :mmddyy))
    else
      summary << t(:no_closing_date)
    end
    summary.compact.join(', ')
  end
end
