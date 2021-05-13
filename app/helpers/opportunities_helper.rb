# frozen_string_literal: true

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
    unless %w[won lost].include?(opportunity.stage)
      amount << number_to_currency(opportunity.amount.to_f, precision: 0)
      amount << (opportunity.discount ? t(:discount_number, number_to_currency(opportunity.discount, precision: 0)) : t(:no_discount))
      amount << t(:probability_number, opportunity.probability.to_i.to_s + '%')
      summary << amount.join(' ')
    end
    summary << if opportunity.closes_on
                 t(:closing_date, l(opportunity.closes_on, format: :mmddyy))
               else
                 t(:no_closing_date)
               end
    summary.compact.join(', ')
  end

  # Generates a select list with the first 25 campaigns
  # and prepends the currently selected campaign, if any.
  #----------------------------------------------------------------------------
  def opportunity_campaign_select(options = {})
    options[:selected] ||= @opportunity.campaign_id.to_i
    selected_campaign = Campaign.find_by_id(options[:selected])
    campaigns = ([selected_campaign] + Campaign.my(current_user).order(:name).limit(25)).compact.uniq
    collection_select :opportunity, :campaign_id, campaigns, :id, :name,
                      { selected: options[:selected], prompt: t(:select_a_campaign) },
                      style: 'width:330px;', class: 'select2'
  end

  # Generates the inline revenue message for the opportunity list table.
  #----------------------------------------------------------------------------
  def opportunity_revenue_message(opportunity, detailed = false)
    msg = []
    won_or_lost = %w[won lost].include?(opportunity.stage)

    msg << content_tag(:b, number_to_currency(opportunity.weighted_amount, precision: 0)) if opportunity.weighted_amount != 0

    unless won_or_lost
      if detailed
        msg << number_to_currency(opportunity.amount.to_f, precision: 0) if opportunity.amount.to_f != 0

        msg << t(:discount) + ' ' + number_to_currency(opportunity.discount, precision: 0) if opportunity.discount.to_f != 0
      end

      msg << t(:probability) + ' ' + opportunity.probability.to_s + '%' if opportunity.probability.to_i != 0
    end

    msg << opportunity_closes_on_message(opportunity, won_or_lost)

    msg.join(' | ').html_safe
  end

  private

  def opportunity_closes_on_message(opportunity, won_or_lost)
    if opportunity.closes_on
      if won_or_lost
        if opportunity.closes_on >= Date.today
          t(:closing_date, l(opportunity.closes_on, format: :mmddyy))
        else
          t(:closed_ago_on, time_ago: distance_of_time_in_words(opportunity.closes_on, Date.today), date: l(opportunity.closes_on, format: :mmddyy))
        end
      elsif opportunity.closes_on > Date.today
        t(:expected_to_close, time: distance_of_time_in_words(Date.today, opportunity.closes_on), date: l(opportunity.closes_on, format: :mmddyy))
      elsif opportunity.closes_on == Date.today
        content_tag(:span, t(:closes_today), class: 'warn')
      else
        content_tag(:span, t(:past_due, distance_of_time_in_words(opportunity.closes_on, Date.today)), class: 'warn')
      end
    else
      t(:no_closing_date)
    end
  end
end
