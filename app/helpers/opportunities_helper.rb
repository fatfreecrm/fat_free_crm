module OpportunitiesHelper

  # Sidebar checkbox control for filtering opportunities by stage.
  #----------------------------------------------------------------------------
  def opportunity_stage_checbox(stage, count)
    checked = (session[:filter_by_opportunity_stage] ? session[:filter_by_opportunity_stage].split(",").include?(stage.to_s) : count > 0)
    check_box_tag("stage[]", stage, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"stage=" + $$("input[name='stage[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
