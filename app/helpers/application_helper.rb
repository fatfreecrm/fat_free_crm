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
  def hidden_if(you_ask)
    { :style => "display: #{you_ask ? 'none' : 'block' };" }
  end

  #----------------------------------------------------------------------------
  def highlightable
    { :onmouseover => "this.style.background='seashell'", :onmouseout => "this.style.background='white'" }
  end
end
