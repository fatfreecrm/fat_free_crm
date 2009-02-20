class HomeController < ApplicationController
  before_filter :require_user, :except => [ :toggle ]
  before_filter "set_current_tab(:dashboard)", :except => [ :toggle ]
  before_filter "hook(:home_before_filter, self, :amazing => true)"

  #----------------------------------------------------------------------------
  def index
    @hello = "world"
    hook(:home_controller, self, :params => "it works!")
    logger.p "Hello, #{@hello}!"
  end
  
  # Save expand/collapse state in the session.                             AJAX
  #----------------------------------------------------------------------------
  def toggle
    render :update do |page|
      if params[:visible] == "false"                          # show
        session[params[:id].intern] = true
        page["#{params[:id]}_arrow"].replace_html "&#9660;"
        callback = "beforeStart"
      else                                                    # hide
        session[params[:id].intern] = nil
        page["#{params[:id]}_arrow"].replace_html "&#9658;"
        callback = "afterFinish"
      end
      page << "Effect.toggle('#{params[:id]}', 'slide', { duration: 0.25, #{callback}: function() { $('#{params[:id]}_intro').toggle(); } });"
    end
  end

end
