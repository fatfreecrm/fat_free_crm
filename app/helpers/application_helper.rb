# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module ApplicationHelper

  def tabs(tabs = FatFreeCRM::Tabs.main)
    if tabs
      @current_tab ||= tabs.first[:text] # Select first tab by default.
      tabs.each { |tab| tab[:active] = (@current_tab == tab[:text] || @current_tab == tab[:url][:controller]) }
    else
      raise FatFreeCRM::MissingSettings, "Tab settings are missing, please run <b>rake crm:setup</b> command."
    end
  end
  
  #----------------------------------------------------------------------------
  def tabless_layout?
    %w(authentications passwords).include?(controller.controller_name) ||
    ((controller.controller_name == "users") && (%w(create new).include?(controller.action_name)))
  end

  # Show existing flash or embed hidden paragraph ready for flash[:notice]
  #----------------------------------------------------------------------------
  def show_flash(options = { :sticky => false })
    [:error, :warning, :info, :notice].each do |type|
      if flash[type]
        html = content_tag(:p, h(flash[type]), :id => "flash")
        return html << content_tag(:script, "crm.flash('#{type}', #{options[:sticky]})", :type => "text/javascript")
      end
    end
    content_tag(:p, nil, :id => "flash", :style => "display:none;")
  end

  #----------------------------------------------------------------------------
  def subtitle(id, hidden = true, text = id.to_s.split("_").last.capitalize)
    content_tag("div",
      link_to_remote("<small>#{ hidden ? "&#9658;" : "&#9660;" }</small> #{text}",
        :url => url_for(:controller => :home, :action => :toggle, :id => id),
        :before => "crm.flip_subtitle(this)"
      ), :class => "subtitle")
  end

  #----------------------------------------------------------------------------
  def inline(id, url, options = {})
    content_tag("div", link_to_inline(id, url, options), :class => options[:class] || "title_tools")
  end

  #----------------------------------------------------------------------------
  def link_to_inline(id, url, options = {})
    text = options[:text] || id.to_s.titleize
    text = (arrow_for(id) << "&nbsp;" << text) unless options[:plain]
    related = (options[:related] ? ", related: '#{options[:related]}'" : "")

    link_to_remote(text,
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
    link_to_remote(t(:edit),
      :method => :get,
      :url    => send("edit_#{name}_path", model),
      :with   => "{ previous: crm.find_form('edit_#{name}') }"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_delete(model)
    name = model.class.name.downcase
    link_to_remote(t(:delete) + "!",
      :method => :delete,
      :url    => send("#{name}_path", model),
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_cancel(url)
    link_to_remote(t(:cancel), :url => url, :method => :get, :with => "{ cancel: true }")
  end

  #----------------------------------------------------------------------------
  def link_to_close(url)
    content_tag("div", "x",
      :class => "close", :title => t(:close_form),
      :onmouseover => "this.style.background='lightsalmon'",
      :onmouseout => "this.style.background='lightblue'",
      :onclick => remote_function(:url => url, :method => :get, :with => "{ cancel: true }")
    )
  end

  #----------------------------------------------------------------------------
  def jumpbox(current)
    [ :campaigns, :accounts, :leads, :contacts, :opportunities ].inject([]) do |html, controller|
      html << link_to_function(controller.to_s.capitalize, "crm.jumper('#{controller}')", :class => (controller == current ? "selected" : ""))
    end.join(" | ")
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
  def one_submit_only(form)
    { :onsubmit => "$('#{form}_submit').disabled = true" }
  end

  #----------------------------------------------------------------------------
  def hidden_if(you_ask)
    you_ask ? hidden : exposed
  end

  #----------------------------------------------------------------------------
  def invisible_if(you_ask)
    you_ask ? invisible : visible
  end

  #----------------------------------------------------------------------------
  def highlightable(id = nil, color = {})
    color = { :on => "seashell", :off => "white" }.merge(color)
    show = (id ? "$('#{id}').style.visibility='visible'" : "")
    hide = (id ? "$('#{id}').style.visibility='hidden'" : "")
    { :onmouseover => "this.style.background='#{color[:on]}'; #{show}",
      :onmouseout  => "this.style.background='#{color[:off]}'; #{hide}"
    }
  end

  #----------------------------------------------------------------------------
  def confirm_delete(model)
    question = %(<span class="warn">#{t(:confirm_delete, model.class.to_s.downcase)}</span>)
    yes = link_to(t(:yes_button), model, :method => :delete)
    no = link_to_function(t(:no_button), "$('menu').update($('confirm').innerHTML)")
    update_page do |page|
      page << "$('confirm').update($('menu').innerHTML)"
      page[:menu].replace_html "#{question} #{yes} : #{no}"
    end
  end

  #----------------------------------------------------------------------------
  def spacer(width = 10)
    image_tag "1x1.gif", :width => width, :height => 1, :alt => nil
  end

  # Reresh sidebar using the action view within the current controller.
  #----------------------------------------------------------------------------
  def refresh_sidebar(action = nil, shake = nil)
    refresh_sidebar_for(controller.controller_name, action, shake)
  end

  # Refresh sidebar using the action view within an arbitrary controller.
  #----------------------------------------------------------------------------
  def refresh_sidebar_for(view, action = nil, shake = nil)
    update_page do |page|
      page[:sidebar].replace_html :partial => "layouts/sidebar", :locals => { :view => view, :action => action }
      page[shake].visual_effect(:shake, :duration => 0.4, :distance => 3) if shake
    end
  end

  # Display web presence mini-icons for Contact or Lead.
  #----------------------------------------------------------------------------
  def web_presence_icons(person)
    [ :blog, :linkedin, :facebook, :twitter ].inject([]) do |links, site|
      url = person.send(site)
      unless url.blank?
        url = "http://" << url unless url.match(/^https?:\/\//)
        links << link_to(image_tag("#{site}.gif", :size => "15x15"), url, :popup => true, :title => t(:open_in_window, url))
      end
      links
    end.join("\n")
  end

  # Ajax helper to refresh current index page once the user selects an option.
  #----------------------------------------------------------------------------
  def redraw(option, value, url = nil)
    if value.is_a?(Array)
      param, value = value.first, value.last
    end
    remote_function(
      :url       => url || send("redraw_#{controller.controller_name}_path"),
      :with      => "{ #{option}: '#{param || value}' }",
      :condition => "$('#{option}').innerHTML != '#{value}'",
      :loading   => "$('#{option}').update('#{value}'); $('loading').show()",
      :complete  => "$('loading').hide()"
    )
  end

  #----------------------------------------------------------------------------
  def options_menu_item(option, key, url = nil)
    name = t("option_#{key}")
    "{ name: \"#{name.titleize}\", on_select: function() {" +
    remote_function(
      :url       => url || send("redraw_#{controller.controller_name}_path"),
      :with      => "{ #{option}: '#{key}' }",
      :condition => "$('#{option}').innerHTML != '#{name}'",
      :loading   => "$('#{option}').update('#{name}'); $('loading').show()",
      :complete  => "$('loading').hide()"
    ) + "}}"
  end

  # Ajax helper to pass browser timezone offset to the server.
  #----------------------------------------------------------------------------
  def get_browser_timezone_offset
    unless session[:timezone_offset]
      remote_function(
        :url  => url_for(:controller => :home, :action => :timezone),
        :with => "{ offset: (new Date()).getTimezoneOffset() }"
      )
    end
  end

  #----------------------------------------------------------------------------
  def activate_facebox
    %Q/document.observe("dom:loaded", function() { new Facebox('#{Setting.base_url}'); });/
  end

  # Users can upload their avatar, and if it's missing we're going to use
  # gravatar. For leads and contacts we always use gravatars.
  #----------------------------------------------------------------------------
  def avatar_for(model, args = {})
    args[:size]  ||= "75x75"
    args[:class] ||= "gravatar"
    if model.avatar
      image_tag(model.avatar.image.url(Avatar.styles[args[:size]]), args)
    elsif model.email
      gravatar(model.email, { :default => default_avatar_url }.merge(args))
    else
      image_tag("avatar.jpg", args)
    end
  end

  # Add default avatar image and invoke original :gravatar_for defined by the
  # gravatar plugin (see vendor/plugins/gravatar/lib/gravatar.rb)
  #----------------------------------------------------------------------------
  def gravatar_for(model, args = {})
    super(model, { :default => default_avatar_url }.merge(args))
  end

  #----------------------------------------------------------------------------
  def default_avatar_url
    "#{request.protocol + request.host_with_port}" + Setting.base_url.to_s + "/images/avatar.jpg"
  end

  # Returns true if partial template exists. Note that the file name of the
  # partial starts with underscore.
  #----------------------------------------------------------------------------
  def partial_exist?(partial, extension = '.html.haml')
    filename = partial.sub(%r{/([^/]*)$}, '/_\\1') + extension
    FileTest.exist?(File.join(RAILS_ROOT, 'app', 'views', filename))
  end

end
