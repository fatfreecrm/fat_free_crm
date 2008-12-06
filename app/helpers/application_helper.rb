# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #-------------------------------------------------------------------
  def tabs
    session[:current_tab] = :home unless session[:current_tab]
    Setting[:tabs].each { |tab| tab[:active] = (tab[:text].downcase.intern == session[:current_tab]) }
  end
  
  #----------------------------------------------------------------------------
  def tabless_layout?
    %w(authentications passwords).include?(controller.controller_name) || ((controller.controller_name == "users") && (controller.action_name == "new"))
  end

  #----------------------------------------------------------------------------
  def show_flash_if_any
    %w(error warning message notice).each do |type|
      return content_tag("p", h(flash[type.to_sym]), :id => "flash_#{type}", :class => "flash_#{type}") if flash[type.to_sym]
    end
    nil
  end

  #----------------------------------------------------------------------------
  def hidden;  { :style => "display:none;"  }; end
  def visible; { :style => "display:block;" }; end

  #----------------------------------------------------------------------------
  def hidden_if(you_ask)
    you_ask ? hidden : visible
  end

  #----------------------------------------------------------------------------
  def highlightable(id = nil)
    {
      :onmouseover => "this.style.background='seashell';" << (id ? "$('#{id}').show()" : ""),
      :onmouseout  => "this.style.background='white';"    << (id ? "$('#{id}').hide()" : "")
    }
  end

end
