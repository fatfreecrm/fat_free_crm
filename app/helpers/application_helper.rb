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
      raise FatFreeCRM::MissingSettings, "Tab settings are missing, please run <b>rake ffcrm:setup</b> command."
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
        html = content_tag(:div, h(flash[type]), :id => "flash")
        flash[type] = nil
        return html << content_tag(:script, "crm.flash('#{type}', #{options[:sticky]})".html_safe, :type => "text/javascript")
      end
    end
    content_tag(:p, nil, :id => "flash", :style => "display:none;")
  end

  #----------------------------------------------------------------------------
  def subtitle(id, hidden = true, text = id.to_s.split("_").last.capitalize)
    content_tag("div",
      link_to("<small>#{ hidden ? "&#9658;" : "&#9660;" }</small> #{text}".html_safe,
        url_for(:controller => :home, :action => :toggle, :id => id),
        :remote => true,
        :onclick => "crm.flip_subtitle(this)"
      ), :class => "subtitle")
  end

  #----------------------------------------------------------------------------
  def section(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    select_id  = "select_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = tag(:br)
    html << content_tag(:div, link_to(t(select_id), "#", :id => select_id), :class => "subtitle_tools")
    html << content_tag(:div, "&nbsp;|&nbsp;".html_safe, :class => "subtitle_tools")
    html << content_tag(:div, link_to_inline(create_id, create_url, :related => dom_id(related), :text => t(create_id)), :class => "subtitle_tools")
    html << content_tag(:div, t(assets), :class => :subtitle, :id => "create_#{asset}_title")
    html << content_tag(:div, "", :class => :remote, :id => create_id, :style => "display:none;")
  end

  #----------------------------------------------------------------------------
  def load_select_popups_for(related, *assets)
    js = assets.map do |asset|
      render(:partial => "shared/select_popup", :locals => { :related => related, :popup => asset })
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
    text = options[:text] || t(id, :default => id.to_s.titleize)
    text = (arrow_for(id) + text) unless options[:plain]
    related = (options[:related] ? "&related=#{options[:related]}" : '')

    link_to(text,
      url + "#{url.include?('?') ? '&' : '?'}cancel=false" + related,
      :remote => true,
      :onclick => "this.href = this.href.replace(/cancel=(true|false)/,'cancel='+ Element.visible('#{id}'));",
      :class => options[:class]
    )
  end

  #----------------------------------------------------------------------------
  def arrow_for(id)
    content_tag(:span, "&#9658;".html_safe, :id => "#{id}_arrow", :class => :arrow)
  end

  #----------------------------------------------------------------------------
  def link_to_edit(record, options = {})
    object = record.is_a?(Array) ? record.last : record

    name = (params[:klass_name] || object.class.name).underscore.downcase
    link_to(t(:edit),
      options[:url] || polymorphic_url(record, :action => :edit),
      :remote  => true,
      :onclick => "this.href = this.href.split('?')[0] + '?previous='+crm.find_form('edit_#{name}');"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_delete(record, options = {})
    object = record.is_a?(Array) ? record.last : record
    confirm = options[:confirm] || nil

    link_to(t(:delete) + "!",
      options[:url] || url_for(record),
      :method => :delete,
      :remote => true,
      :onclick => visual_effect(:highlight, dom_id(object), :startcolor => "#ffe4e1"),
      :confirm => confirm
    )
  end

  #----------------------------------------------------------------------------
  def link_to_discard(object)
    current_url = (request.xhr? ? request.referer : request.fullpath)
    parent, parent_id = current_url.scan(%r|/(\w+)/(\d+)|).flatten

    link_to(t(:discard),
      url_for(:controller => parent, :action => :discard, :id => parent_id, :attachment => object.class.name, :attachment_id => object.id),
      :method  => :post,
      :remote  => true,
      :onclick => visual_effect(:highlight, dom_id(object), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_cancel(url, params = {})
    url = params[:url] if params[:url]
    link_to(t(:cancel),
      url + "#{url.include?('?') ? '&' : '?'}cancel=true",
      :remote => true
    )
  end

  #----------------------------------------------------------------------------
  def link_to_close(url)
    link_to("x", url + "#{url.include?('?') ? '&' : '?'}cancel=true",
      :remote => true,
      :class => "close",
      :title => t(:close_form)
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
    render :partial => "shared/inline_styles", :locals => { :models => models }
  end

  #----------------------------------------------------------------------------
  def hidden;    { :style => "display:none;"       }; end
  def exposed;   { :style => "display:block;"      }; end
  def invisible; { :style => "visibility:hidden;"  }; end
  def visible;   { :style => "visibility:visible;" }; end

  #----------------------------------------------------------------------------
  def one_submit_only(form)
    { :onsubmit => "$$('#'+this.id+' input[type=\"submit\"]')[0].disabled = true" }
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
        if site == :skype then
          url = "callto:" << url
        else
          url = "http://" << url unless url.match(/^https?:\/\//)
        end
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

  # Ajax helper to refresh current index page once the user changes pagination per_page.
  #-------------------------------------------------------------------------------------
  def redraw_pagination(value)
    remote_function(
      :url       => send("redraw_#{controller.controller_name}_path"),
      :with      => "'per_page=#{value}'",
      :condition => "jQuery('.per_page_options .current').html() != '#{value}'",
      :loading   => "$('loading').show()",
      :complete  => "$('loading').hide()"
    )
  end

  #----------------------------------------------------------------------------
  def options_menu_item(option, key, url = nil)
    name = t("option_#{key}")
    "{ name: \"#{name.titleize}\", on_select: function() {" +
    remote_function(
      :url       => url || send("redraw_#{controller.controller_name}_path"),
      :with      => "'#{option}=#{key}&query=' + $(\"query\").value",
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

  # Entities can have associated avatars or gravatars. Only calls Gravatar
  # in production env. Gravatar won't serve default images if they are not
  # publically available: http://en.gravatar.com/site/implement/images
  #----------------------------------------------------------------------------
  def avatar_for(model, args = {})
    args = { :class => 'gravatar', :size => :large }.merge(args)

    if model.respond_to?(:avatar) and model.avatar.present?
      Avatar
      image_tag(model.avatar.image.url(args[:size]), args)
    else
      args = Avatar.size_from_style!(args) # convert size format :large => '75x75'
      if (Rails.env == 'production') and model.respond_to?(:email) and model.email.present?
        args = { :gravatar => { :default => image_path('avatar.jpg') } }.merge(args)
        gravatar_image_tag(model.email, args)
      else
        image_tag("avatar.jpg", args)
      end
    end

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
  def links_to_export(action=:index)
    token = current_user.single_access_token
    url_params = {:action => action}
    url_params.merge!(:id => params[:id]) unless params[:id].blank?
    url_params.merge!(:query => params[:query]) unless params[:query].blank?
    url_params.merge!(:q => params[:q]) unless params[:q].blank?
    url_params.merge!(:view => @view) unless @view.blank? # tasks
    url_params.merge!(:id => params[:id]) unless params[:id].blank?

    exports = %w(xls csv).map do |format|
      link_to(format.upcase, url_params.merge(:format => format), :title => I18n.t(:"to_#{format}")) unless action.to_s == "show"
    end

    feeds = %w(rss atom).map do |format|
      link_to(format.upcase, url_params.merge(:format => format, :authentication_credentials => token), :title => I18n.t(:"to_#{format}"))
    end

    links = %W(perm).map do |format|
      link_to(format.upcase, url_params, :title => I18n.t(:"to_#{format}"))
    end

    (exports + feeds + links).compact.join(' | ')
  end

  def user_options
    User.all.map {|u| [u.full_name, u.id]}
  end

  def group_options
    Group.all.map {|g| [g.name, g.id]}
  end

  def list_of_entities
    ENTITIES
  end

  def entity_filter_checkbox(name, value, count)
    checked = (session["#{controller_name}_filter"] ? session["#{controller_name}_filter"].split(",").include?(value.to_s) : count.to_i > 0)
    values = %Q{$$("input[name='#{name}[]']").findAll(function (el) { return el.checked }).pluck("value")}
    params = h(%Q{"#{name}=" + #{values} + "&query=" + $("query").value})

    onclick = remote_function(
      :url      => { :action => :filter },
      :with     => params,
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    check_box_tag("#{name}[]", value, checked, :id => value, :onclick => onclick)
  end


  # Create a column in the 'asset_attributes' table.
  #----------------------------------------------------------------------------
  def col(title, value, last = false, email = false)
    # Parse and format urls as links.
    fmt_value = (value.to_s || "").gsub("\n", "<br />")
    fmt_value = if email
        link_to_email(fmt_value)
      else
        fmt_value.gsub(/((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/\+#]*[\w\-\@?^=%&amp;\/\+#])?)/, "<a href=\"\\1\">\\1</a>")
      end
    %Q^<th#{last ? " class=\"last\"" : ""}>#{title}:</th>
  <td#{last ? " class=\"last\"" : ""}>#{fmt_value}</td>^.html_safe
  end

  #----------------------------------------------------------------------------
  # Combines the 'subtitle' helper with the small info text on the same line.
  def section_title(id, hidden = true, text = nil, info_text = nil)
    text = id.to_s.split("_").last.capitalize if text == nil
    content_tag("div", :class => "subtitle show_attributes") do
      content = link_to("<small>#{ hidden ? "&#9658;" : "&#9660;" }</small> #{text}".html_safe,
        url_for(:controller => :home, :action => :toggle, :id => id),
        :remote  => true,
        :onclick => "crm.flip_subtitle(this)"
      )
      content << content_tag("small", info_text.to_s, {:class => "subtitle_inline_info", :id => "#{id}_intro", :style => hidden ? "" : "display:none;"})
    end
  end
end
