module LeadsHelper

  # We need this because standard Rails [select] turns &#9733; into &amp;#9733;
  #----------------------------------------------------------------------------
  def rating_select(name, options = {})
    stars = (1..5).inject({}) { |hash, star| hash[star] = "&#9733;" * star; hash }.sort
    options_for_select = %(<option value="0">-- None --</option>)
    options_for_select << stars.inject([]) {|array, star| array << %(<option value="#{star.first}">#{star.last}</option>); array }.join
    select_tag name, options_for_select, options
  end

  #----------------------------------------------------------------------------
  def status_checbox(status)
    checked = (session[:filter_by_lead_status] ? session[:filter_by_lead_status].split(",").include?(status.to_s) : true)
    check_box_tag("status[]", status, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"status=" + $$("input[name='status[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
