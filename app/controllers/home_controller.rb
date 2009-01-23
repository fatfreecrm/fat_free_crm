class HomeController < ApplicationController
  before_filter :require_user, :except => [ :toggle_form_section ]
  before_filter "set_current_tab(:dashboard)", :except => [ :toggle_form_section ]
  before_filter "hook(:home_before_filter, self, :amazing => true)"

  #----------------------------------------------------------------------------
  def index
    @hello = "world"
    hook(:home_controller, self, :params => "it works!")
  end
  
  # Ajax PUT /toggle_form_section
  #----------------------------------------------------------------------------
  def toggle_form_section
    uri = URI.parse(request.env["HTTP_REFERER"])
    path = uri.path.split("/")
    key = "#{params[:id]}_#{path[1]}_#{path[-1]}".intern

    render :update do |page|
      if params[:visible] == "false"                          # show
        session[key] = true
        page["#{params[:id]}_arrow"].replace_html "&#9660;"
        callback = "beforeStart"
      else                                                    # hide
        session[key] = nil
        page["#{params[:id]}_arrow"].replace_html "&#9658;"
        callback = "afterFinish"
      end
      page << "Effect.toggle('#{params[:id]}', 'slide', { duration: 0.25, #{callback}: function() { $('#{params[:id]}_intro').toggle(); } });"
    end
  end

end
