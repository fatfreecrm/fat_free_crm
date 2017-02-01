# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module OpportunitiesHelper
  # Sidebar checkbox control for filtering opportunities by stage.
  #----------------------------------------------------------------------------
  def opportunity_stage_checkbox(stage, count)
    entity_filter_checkbox(:stage, stage, count)
  end

  # Opportunity summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def opportunity_summary(opportunity)
    summary = []
    amount = []
    summary << (opportunity.stage ? t(opportunity.stage) : t(:other))
    summary << number_to_currency(opportunity.weighted_amount, precision: 0)
    unless %w(won lost).include?(opportunity.stage)
      amount << number_to_currency(opportunity.amount || 0, precision: 0)
      amount << (opportunity.discount ? t(:discount_number, number_to_currency(opportunity.discount, precision: 0)) : t(:no_discount))
      amount << t(:probability_number, (opportunity.probability || 0).to_s + '%')
      summary << amount.join(' ')
    end
    if opportunity.closes_on
      summary << t(:closing_date, l(opportunity.closes_on, format: :mmddyy))
    else
      summary << t(:no_closing_date)
    end
    summary.compact.join(', ')
  end

  # Generates a select list with the first 25 campaigns
  # and prepends the currently selected campaign, if any.
  #----------------------------------------------------------------------------
  def opportunity_campaign_select(options = {})
    options[:selected] ||= @opportunity.campaign_id || 0
    selected_campaign = Campaign.find_by_id(options[:selected])
    campaigns = ([selected_campaign] + Campaign.my.order(:name).limit(25)).compact.uniq
    collection_select :opportunity, :campaign_id, campaigns, :id, :name, options,
                      "data-placeholder": t(:select_a_campaign),
                      "data-url": auto_complete_campaigns_path(format: 'json'),
                      style: "width:330px; display:none;",
                      class: 'ajax_chosen'
  end
end
