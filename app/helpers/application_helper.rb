# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
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

  def tabs(tabs = nil)
    tabs ||= controller_path =~ /admin/ ? FatFreeCRM::Tabs.admin : FatFreeCRM::Tabs.main
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
      link_to_remote("<small>#{ hidden ? "&#9658;" : "&#9660;" }</small> #{text}".html_safe,
        :url    => url_for(:controller => :home, :action => :toggle, :id => id),
        :before => "crm.flip_subtitle(this)"
      ), :class => "subtitle")
  end

  #----------------------------------------------------------------------------
  def section(related, assets)
    asset = assets.to_s.singularize
    create_id  = :"create_#{asset}"
    select_id  = :"select_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = "<br />".html_safe
    html << content_tag(:div, link_to(t(select_id), "#", :id => select_id), :class => "subtitle_tools")
    html << content_tag(:div, "&nbsp;|&nbsp;".html_safe, :class => "subtitle_tools")
    html << content_tag(:div, link_to_inline(create_id, create_url, :related => dom_id(related), :text => t(create_id)), :class => "subtitle_tools")
    html << content_tag(:div, t(assets), :class => :subtitle, :id => :"create_#{asset}_title")
    html << content_tag(:div, "", :class => :remote, :id => create_id, :style => "display:none;")
  end

  #----------------------------------------------------------------------------
  def load_select_popups_for(related, *assets)
    js = assets.map do |asset|
      render(:partial => "common/select_popup", :locals => { :related => related, :popup => asset })
    end.join

    content_for(:javascript_epilogue) do
      raw "document.observe('dom:loaded', function() { #{js} });"
    end
  end

  # We need this because standard Rails [select] turns &#9733; into &amp;#9733;
  #----------------------------------------------------------------------------
  def rating_select(name, options = {})
    stars = Hash[ (1..5).map { |star| [ star, "&#9733;" * star ] } ].sort
    options_for_select = %Q(<option value="0"#{options[:selected].to_i == 0 ? ' selected="selected"' : ''}>#{t :select_none}</option>)
    options_for_select << stars.map { |star| %(<option value="#{star.first}"#{options[:selected] == star.first ? ' selected="selected"' : ''}>#{star.last}</option>) }.join
    select_tag name, options_for_select.html_safe, options
  end

  #----------------------------------------------------------------------------
  def link_to_inline(id, url, options = {})
    text = options[:text] || id.to_s.titleize
    text = (arrow_for(id) + text) unless options[:plain]
    related = (options[:related] ? "+'&related=#{options[:related]}'" : '')

    link_to_remote(text,
      :url    => url,
      :method => :get,
      :with   => "'cancel='+Element.visible('#{id}')#{related}"
    )
  end

  #----------------------------------------------------------------------------
  def arrow_for(id)
    content_tag(:span, "&#9658;".html_safe, :id => "#{id}_arrow", :class => :arrow)
  end

  #----------------------------------------------------------------------------
  def link_to_edit(model, params = {})
    name = model.class.name.underscore.downcase
    link_to_remote(t(:edit),
      :url    => params[:url] || send(:"edit_#{name}_path", model),
      :method => :get,
      :with   => "'previous='+crm.find_form('edit_#{name}')"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_delete(model, params = {})
    name = model.class.name.underscore.downcase
    link_to_remote(t(:delete) + "!",
      :url    => params[:url] || url_for(model),
      :method => :delete,
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_discard(model)
    name = model.class.name.downcase
    current_url = (request.xhr? ? request.referer : request.fullpath)
    parent, parent_id = current_url.scan(%r|/(\w+)/(\d+)|).flatten

    link_to_remote(t(:discard),
      :url    => url_for(:controller => parent, :action => :discard, :id => parent_id),
      :method => :post,
      :with   => "'attachment=#{model.class.name}&attachment_id=#{model.id}'",
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_cancel(url, params = {})
    link_to_remote(t(:cancel),
      :url    => params[:url] || url,
      :method => :get,
      :with   => "'cancel=true'"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_close(url)
    content_tag("div", "x",
      :class => "close", :title => t(:close_form),
      :onmouseover => "this.style.background='lightsalmon'",
      :onmouseout => "this.style.background='lightblue'",
      :onclick => remote_function(:url => url, :method => :get, :with => "'cancel=true'")
    )
  end

  # Bcc: to dropbox address if the dropbox has been set up.
  #----------------------------------------------------------------------------
  def link_to_email(email, length = nil)
    name = (length ? truncate(email, :length => length) : email)
    if Setting.email_dropbox && Setting.email_dropbox[:address].present?
      mailto = "#{email}?bcc=#{Setting.email_dropbox[:address]}"
    else
      mailto = email
    end
    link_to(h(name), "mailto:#{mailto}", :title => email)
  end

  #----------------------------------------------------------------------------
  def jumpbox(current)
    tabs = [ :campaigns, :accounts, :leads, :contacts, :opportunities ]
    current = tabs.first unless tabs.include?(current)
    tabs.map do |tab|
      link_to_function(t("tab_#{tab}"), "crm.jumper('#{tab}')", :class => (tab == current ? 'selected' : ''))
    end.join(" | ").html_safe
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
  def confirm_delete(model, params = {})
    question = %(<span class="warn">#{t(:confirm_delete, model.class.to_s.downcase)}</span>).html_safe
    yes = link_to(t(:yes_button), params[:url] || model, :method => :delete)
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
      page[shake].visual_effect(:shake, :duration => 0.2, :distance => 3) if shake
    end
  end

  # Display web presence mini-icons for Contact or Lead.
  #----------------------------------------------------------------------------
  def web_presence_icons(person)
    [ :blog, :linkedin, :facebook, :twitter, :skype ].map do |site|
      url = person.send(site)
      unless url.blank?
        url = "http://" << url unless url.match(/^https?:\/\//)
        link_to(image_tag("#{site}.gif", :size => "15x15"), url, :"data-popup" => true, :title => t(:open_in_window, url))
      end
    end.compact.join("\n").html_safe
  end

  # Ajax helper to refresh current index page once the user selects an option.
  #----------------------------------------------------------------------------
  def redraw(option, value, url = nil)
    if value.is_a?(Array)
      param, value = value.first, value.last
    end
    remote_function(
      :url       => url || send("redraw_#{controller.controller_name}_path"),
      :with      => "'#{option}=#{param || value}'",
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
      :with      => "'#{option}=#{key}'",
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
        :url  => timezone_path,
        :with => "'offset='+(new Date()).getTimezoneOffset()"
      )
    end
  end

  #----------------------------------------------------------------------------
  def localize_calendar_date_select
    update_page_tag do |page|
      page.assign '_translations', { 'OK' => t('calendar_date_select.ok'), 'Now' => t('calendar_date_select.now'), 'Today' => t('calendar_date_select.today'), 'Clear' => t('calendar_date_select.clear') }
      page.assign 'Date.weekdays', t('date.abbr_day_names')
      page.assign 'Date.months', t('date.month_names')[1..-1]
    end
  end

  # Users can upload their avatar, and if it's missing we're going to use
  # gravatar. For leads and contacts we always use gravatars.
  #----------------------------------------------------------------------------
  def avatar_for(model, args = {})
    args = { :class => 'gravatar', :size => '75x75' }.merge(args)
    if model.avatar
      image_tag(model.avatar.image.url(Avatar.styles[args[:size]]), args)
    elsif model.email
      gravatar_image_tag(model.email, { :gravatar => { :default => default_avatar_url } }.merge(args))
    else
      image_tag("avatar.jpg", args)
    end
  end

  # Gravatar helper that adds default CSS class and image URL.
  #----------------------------------------------------------------------------
  def gravatar_for(model, args = {})
    args = { :class => 'gravatar', :gravatar => { :default => default_avatar_url } }.merge(args)
    gravatar_image_tag(model.email, args)
  end

  #----------------------------------------------------------------------------
  def default_avatar_url
    "#{request.protocol + request.host_with_port}" + Setting.base_url.to_s + "/images/avatar.jpg"
  end

  # Returns default permissions intro.
  #----------------------------------------------------------------------------
  def get_default_permissions_intro(access, text)
    case access
      when "Private" then t(:permissions_intro_private, text)
      when "Public"  then t(:permissions_intro_public,  text)
      when "Shared"  then t(:permissions_intro_shared,  text)
    end
  end

  # Render a text field that is part of compound address.
  #----------------------------------------------------------------------------
  def address_field(form, object, attribute, extra_styles)
    hint = "#{t(attribute)}..."
    if object.send(attribute).blank?
      object.send("#{attribute}=", hint)
      form.text_field(attribute,
        :hint    => true,
        :style   => "margin-top: 6px; color:silver; #{extra_styles}",
        :onfocus => "crm.hide_hint(this)",
        :onblur  => "crm.show_hint(this, '#{hint}')"
      )
    else
      form.text_field(attribute,
        :hint    => false,
        :style   => "margin-top: 6px; #{extra_styles}",
        :onfocus => "crm.hide_hint(this, '#{escape_javascript(object.send(attribute))}')",
        :onblur  => "crm.show_hint(this, '#{hint}')"
      )
    end
  end

  # Return true if:
  #   - it's an Ajax request made from the asset landing page (i.e. create opportunity
  #     from a contact landing page) OR
  #   - we're actually showing asset landing page.
  #----------------------------------------------------------------------------
  def shown_on_landing_page?
    !!((request.xhr? && request.referer =~ %r|/\w+/\d+|) ||
       (!request.xhr? && request.fullpath =~ %r|/\w+/\d+|))
  end

  # Helper to display links to supported data export formats.
  #----------------------------------------------------------------------------
  def links_to_export
    token = @current_user.single_access_token
    path = if controller.controller_name == 'home'
      activities_path
    elsif controller.class.to_s.starts_with?("Admin::")
      send("admin_#{controller.controller_name}_path")
    else
      send("#{controller.controller_name}_path")
    end

    exports = %w(xls csv).map do |format|
      link_to(format.upcase, "#{path}.#{format}", :title => I18n.t(:"to_#{format}"))
    end

    feeds = %w(rss atom).map do |format|
      link_to(format.upcase, "#{path}.#{format}?authentication_credentials=#{token}", :title => I18n.t(:"to_#{format}"))
    end

    (exports + feeds).join(' | ')
  end
end

