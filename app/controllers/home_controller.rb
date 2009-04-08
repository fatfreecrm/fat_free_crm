class HomeController < ApplicationController
  before_filter :require_user, :except => [ :toggle ]
  before_filter "set_current_tab(:dashboard)", :except => [ :toggle ]
  before_filter "hook(:home_before_filter, self, :amazing => true)"

  #----------------------------------------------------------------------------
  def index
    @hello = "Hello world" # The hook below can access controller's instance variables.
    hook(:home_controller, self, :params => "it works!")

    @activities = Activity.latest
  end
  
  # Save expand/collapse state in the session.                             AJAX
  #----------------------------------------------------------------------------
  def toggle
    if session[params[:id].to_sym]
      session.data.delete(params[:id].to_sym)
    else
      session[params[:id].to_sym] = true
    end
    render :nothing => true
  end

end
