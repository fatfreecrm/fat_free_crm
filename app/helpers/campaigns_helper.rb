# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module CampaignsHelper
  # Sidebar checkbox control for filtering campaigns by status.
  #----------------------------------------------------------------------------
  def campaign_status_checkbox(status, count)
    entity_filter_checkbox(:status, status, count)
  end

  #----------------------------------------------------------------------------
  def performance(actual, target)
    if target.to_i.positive? && actual.to_i.positive?
      if target > actual
        n = 100 - actual * 100 / target
        html = content_tag(:span, "(-#{number_to_percentage(n, precision: 1)})", class: "warn")
      else
        n = actual * 100 / target - 100
        html = content_tag(:span, "(+#{number_to_percentage(n, precision: 1)})", class: "cool")
      end
    end
    html || ""
  end

  # Quick campaign summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def campaign_summary(campaign)
    status  = render file: "campaigns/_status.html.haml",  locals: { campaign: campaign }
    metrics = render file: "campaigns/_metrics.html.haml", locals: { campaign: campaign }
    "#{t(campaign.status)}, " + [status, metrics].map { |str| strip_tags(str) }.join(' ').delete("\n")
  end
end
