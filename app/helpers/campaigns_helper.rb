module CampaignsHelper

  #----------------------------------------------------------------------------
  def status_checbox(status)
    checked = (session[:filter_by_campaign_status] ? session[:filter_by_campaign_status].split(",").include?(status.to_s) : true)
    check_box_tag("status[]", status, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"status=" + $$("input[name='status[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
