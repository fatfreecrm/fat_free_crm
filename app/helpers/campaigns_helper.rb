module CampaignsHelper

  # Sidebar checkbox control for filtering campaigns by status.
  #----------------------------------------------------------------------------
  def campaign_status_checbox(status, count)
    checked = (session[:filter_by_campaign_status] ? session[:filter_by_campaign_status].split(",").include?(status.to_s) : count > 0)
    check_box_tag("status[]", status, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"status=" + $$("input[name='status[]']").findAll(function (el) { return el.checked }).pluck("value")/))
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

end
