# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #-------------------------------------------------------------------
  def tabs
    session[:current_tab] ||= :home
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
  def subtitle(id, hidden = true, text = id.to_s.split("_").last.capitalize)
    content_tag("div",
      link_to_remote("<small id='#{id}_arrow'>#{ hidden ? "&#9658;" : "&#9660;" }</small> #{text}",
        :url => url_for(:controller => :home, :action => :toggle, :id => id),
        :with => "'visible=' + Element.visible('#{id}')"
      ), :class => "subtitle")
  end

  #----------------------------------------------------------------------------
  def inline(id, url, options = {})
    content_tag("div", link_to_inline(id, url, options), :class => options[:class] || "title_tools")
  end

  #----------------------------------------------------------------------------
  def link_to_inline(id, url, options = {})
    text    = options[:text] || id.to_s.titleize
    related = (options[:related] ? ", related: '#{options[:related]}'" : "")

    link_to_remote(arrow_for(id) << "&nbsp;" << text,
      :url    => url,
      :method => :get,
      :with   => "{ cancel: Element.visible('#{id}')#{related} }"
    )
  end

  #----------------------------------------------------------------------------
  def arrow_for(id)
    content_tag(:abbr, "&#9658;", :id => "#{id}_arrow")
  end

  #----------------------------------------------------------------------------
  def link_to_edit(model)
    name = model.class.name.downcase
    link_to_remote("Edit",
      :method => :get,
      :url    => send("edit_#{name}_path", model),
      :with   => "{ open: crm.find_form('edit_#{name}') }"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_delete(model)
    name = model.class.name.downcase
    link_to_remote("Delete!",
      :method => :delete,
      :url    => send("#{name}_path", model),
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def styles_for(*models)
    render :partial => "common/inline_styles", :locals => { :models => models }
  end

  #----------------------------------------------------------------------------
  def hidden;    { :style => "display:none;"       }; end
  def exposed;   { :style => "display:block;"      }; end
  def invisible; { :style => "visibility:hidden;"  }; end
  def visible;   { :style => "visibility:visible;" }; end

  #----------------------------------------------------------------------------
  def hidden_if(you_ask)
    you_ask ? hidden : exposed
  end

  #----------------------------------------------------------------------------
  def invisible_if(you_ask)
    you_ask ? invisible : visible
  end

  #----------------------------------------------------------------------------
  def highlightable(id = nil, use_hide_and_show = false)
    if use_hide_and_show
      show = (id ? "$('#{id}').show()" : "")
      hide = (id ? "$('#{id}').hide()" : "")
    else
      show = (id ? "$('#{id}').style.visibility='visible'" : "")
      hide = (id ? "$('#{id}').style.visibility='hidden'" : "")
    end
    {
      :onmouseover => "this.style.background='seashell'; #{show}",
      :onmouseout  => "this.style.background='white'; #{hide}"
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

  #----------------------------------------------------------------------------
  def time_ago(whenever)
    distance_of_time_in_words(Time.now, whenever) << " ago"
  end

end
