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
    yes = link_to("<b>Yes</b>", model, :method => :delete)
    no = link_to_function("<b>No</b>", "$$('.tlink')[0].update($('confirm').innerHTML)")
    "$('confirm').update($$('.tlink')[0].innerHTML); $$('.tlink')[0].update('#{question} #{escape_javascript(yes)} : #{escape_javascript(no)}');"
  end

end
