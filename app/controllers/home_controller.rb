class HomeController < ApplicationController
  before_filter :require_user, :except => [ :toggle_form_section ]
  before_filter "set_current_tab(:home)", :except => [ :toggle_form_section ]
  
  #----------------------------------------------------------------------------
  def index
  end
  
  # Ajax PUT /toggle_form_section
  #----------------------------------------------------------------------------
  def toggle_form_section
    uri = URI.parse(request.env["HTTP_REFERER"])
    key = (params[:id] + uri.path).gsub("/", "_").intern

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
