module LeadsHelper
  RATING_STARS = 5

  #----------------------------------------------------------------------------
  def stars_for(lead)
    if lead.rating == RATING_STARS
      "&#9733;" * RATING_STARS
    elsif lead.rating.nil? || lead.rating == 0
      %(<font color="gainsboro">#{"&#9733;" * RATING_STARS}</font>)
    else
      "&#9733;" * lead.rating + %(<font color="gainsboro">#{"&#9733;" * (RATING_STARS - lead.rating)}</font>)
    end
  end

  #----------------------------------------------------------------------------
  def link_to_convert(lead)
    link_to_remote("Convert",
      :method => :get,
      :url    => convert_lead_path(lead),
      :with   => "{ previous: crm.find_form('edit_lead') }"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_reject(lead)
    link_to_remote("Reject!", :method => :put, :url => reject_lead_path(lead))
  end

  #----------------------------------------------------------------------------
  def confirm_reject(lead)
    question = %(<span class="warn">Are you sure you want to reject this lead?</span>)
    yes = link_to("Yes", reject_lead_path(lead), :method => :put)
    no = link_to_function("No", "$('menu').update($('confirm').innerHTML)")
    update_page do |page|
      page << "$('confirm').update($('menu').innerHTML)"
      page[:menu].replace_html "#{question} #{yes} : #{no}"
    end
  end

  # We need this because standard Rails [select] turns &#9733; into &amp;#9733;
  #----------------------------------------------------------------------------
  def rating_select(name, options = {})
    stars = (1..5).inject({}) { |hash, star| hash[star] = "&#9733;" * star; hash }.sort
    options_for_select = %Q(<option value="0"#{options[:selected].to_i == 0 ? ' selected="selected"' : ''}>-- None --</option>)
    options_for_select << stars.inject([]) {|array, star| array << %(<option value="#{star.first}"#{options[:selected] == star.first ? ' selected="selected"' : ''}>#{star.last}</option>); array }.join
    select_tag name, options_for_select, options
  end

  # Sidebar checkbox control for filtering leads by status.
  #----------------------------------------------------------------------------
  def lead_status_checbox(status, count)
    checked = (session[:filter_by_lead_status] ? session[:filter_by_lead_status].split(",").include?(status.to_s) : count > 0)
    check_box_tag("status[]", status, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"status=" + $$("input[name='status[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
