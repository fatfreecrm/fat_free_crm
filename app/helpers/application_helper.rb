# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #-------------------------------------------------------------------
  def tabs
    session[:current_tab] = :home unless session[:current_tab]
    Setting[:tabs].each { |tab| tab[:active] = (tab[:text].downcase.intern == session[:current_tab]) }
  end
  
  #----------------------------------------------------------------------------
  def tabless_layout?
    %w(authentications passwords).include?(controller.controller_name) ||
    ((controller.controller_name == "users") && (%w(create new).include?(controller.action_name)))
  end

  #----------------------------------------------------------------------------
  def show_flash_if_any
    %w(error warning message notice).each do |type|
      return content_tag("p", h(flash[type.to_sym]), :id => "flash_#{type}", :class => "flash_#{type}") if flash[type.to_sym]
    end
    nil
  end

  #----------------------------------------------------------------------------
  def subtitle(id, text = id.to_s.capitalize)
    link_to_remote "<small id='#{id}_arrow'>&#9658;</small> #{text}", :url => url_for(:controller => :home, :action => :toggle_form_section, :id => id), :with => "'visible=' + Element.visible('#{id}')"
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

  #----------------------------------------------------------------------------
  def confirm_delete(model)
    question = %(<span class="warn">Are you sure you want to delete this #{model.class.to_s.downcase}?</span>)
    yes = link_to("Yes", model, :method => :delete)
    no = link_to_function("No", "$('menu').update($('confirm').innerHTML)")
    update_page do |page|
      page << "$('confirm').update($('menu').innerHTML)"
      page[:menu].replace_html "#{question} #{yes} : #{no}"
    end
  end

  #----------------------------------------------------------------------------
  def spacer(width = 10)
    image_tag "1x1.gif", :width => width, :height => 1, :alt => nil
  end

end
