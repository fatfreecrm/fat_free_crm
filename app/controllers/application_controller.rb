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

class ApplicationController < ActionController::Base

  helper_method :klass
  helper_method :current_user_session, :current_user, :can_signup?
  helper_method :called_from_index_page?, :called_from_landing_page?

  before_filter :set_context
  before_filter :clear_setting_cache
  before_filter "hook(:app_before_filter, self)"
  after_filter  "hook(:app_after_filter,  self)"

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => '165eb65bfdacf95923dad9aea10cc64a'

  def klass
    @klass ||= controller_name.classify.constantize
  end

private
  #----------------------------------------------------------------------------
  def clear_setting_cache
    Setting.clear_cache!
  end

  #----------------------------------------------------------------------------
  def set_context
    Time.zone = ActiveSupport::TimeZone[session[:timezone_offset]] if session[:timezone_offset]
    I18n.locale = Setting.locale if Setting.locale
  end

  #----------------------------------------------------------------------------
  def set_current_tab(tab = controller_name)
    @current_tab = tab
  end

  #----------------------------------------------------------------------------
  def current_user_session
    @current_user_session ||= Authentication.find
    if @current_user_session && @current_user_session.record.suspended?
      @current_user_session = nil
    end
    @current_user_session
  end

  #----------------------------------------------------------------------------
  def current_user
    unless @current_user
      @current_user = (current_user_session && current_user_session.record)
      if @current_user
        @current_user.set_individual_locale
        @current_user.set_single_access_token
      end
      User.current_user = @current_user
    end
    @current_user
  end

  #----------------------------------------------------------------------------
  def require_user
    unless current_user
      store_location
      flash[:notice] = t(:msg_login_needed) if request.fullpath != "/"
      respond_to do |format|
        format.html { redirect_to login_url }
        format.js   { render(:index) { |page| page.redirect_to login_url } }
      end
    end
  end

  #----------------------------------------------------------------------------
  def require_no_user
    if current_user
      store_location
      flash[:notice] = t(:msg_logout_needed)
      redirect_to profile_url
    end
  end

  #----------------------------------------------------------------------------
  def get_users
    @users ||= User.except(current_user)
  end

  #----------------------------------------------------------------------------
  def store_location
    session[:return_to] = request.fullpath
  end

  #----------------------------------------------------------------------------
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  #----------------------------------------------------------------------------
  def can_signup?
    [ :allowed, :needs_approval ].include? Setting.user_signup
  end

  #----------------------------------------------------------------------------
  def called_from_index_page?(controller = controller_name)
    if controller != "tasks"
      request.referer =~ %r(/#{controller}$)
    else
      request.referer =~ /tasks\?*/
    end
  end

  #----------------------------------------------------------------------------
  def called_from_landing_page?(controller = controller_name)
    request.referer =~ %r(/#{controller}/\w+)
  end

  #----------------------------------------------------------------------------
  def update_recently_viewed
    subject = instance_variable_get("@#{controller_name.singularize}")
    if subject
      Activity.log(current_user, subject, :viewed)
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_not_found(*types)
    asset = self.controller_name.singularize
    flick = case self.action_name
      when "destroy" then "delete"
      when "promote" then "convert"
      else self.action_name
    end
    if self.action_name == "show"
      # If asset does exist, but is not viewable to the current user..
      if asset.capitalize.constantize.exists?(params[:id])
        flash[:warning] = t(:msg_asset_not_authorized, asset)
      else
        flash[:warning] = t(:msg_asset_not_available, asset)
      end
    else
      flash[:warning] = t(:msg_cant_do, :action => flick, :asset => asset)
    end
    respond_to do |format|
      format.html { redirect_to :action => :index }                          if types.include?(:html)
      format.js   { render(:update) { |page| page.reload } }                 if types.include?(:js)
      format.json { render :text => flash[:warning], :status => :not_found } if types.include?(:json)
      format.xml  { render :text => flash[:warning], :status => :not_found } if types.include?(:xml)
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_related_not_found(related, *types)
    asset = self.controller_name.singularize
    asset = "note" if asset == "comment"
    flash[:warning] = t(:msg_cant_create_related, :asset => asset, :related => related)
    url = send("#{related.pluralize}_path")
    respond_to do |format|
      format.html { redirect_to url }                                        if types.include?(:html)
      format.js   { render(:update) { |page| page.redirect_to url } }        if types.include?(:js)
      format.json { render :text => flash[:warning], :status => :not_found } if types.include?(:json)
      format.xml  { render :text => flash[:warning], :status => :not_found } if types.include?(:xml)
    end
  end

  # Proxy current page for any of the controllers by storing it in a session.
  #----------------------------------------------------------------------------
  def current_page=(page)
    @current_page = session["#{controller_name}_current_page".to_sym] = page.to_i
  end

  #----------------------------------------------------------------------------
  def current_page
    page = params[:page] || session["#{controller_name}_current_page".to_sym] || 1
    @current_page = page.to_i
  end

  # Proxy current search query for any of the controllers by storing it in a session.
  #----------------------------------------------------------------------------
  def current_query=(query)
    @current_query = session["#{controller_name}_current_query".to_sym] = query
  end

  #----------------------------------------------------------------------------
  def current_query
    @current_query = params[:query] || session["#{controller_name}_current_query".to_sym] || ""
  end

  # Somewhat simplistic parser that extracts query and hash-prefixed tags from
  # the search string and returns them as two element array, for example:
  #
  # "#real Billy Bones #pirate" => [ "Billy Bones", "real, pirate" ]
  #----------------------------------------------------------------------------
  def parse_query_and_tags(search_string)
    query, tags = [], []
    search_string.scan(/[\w@\-\.#]+/).each do |token|
      if token.starts_with?("#")
        tags << token[1 .. -1]
      else
        query << token
      end
    end
    [ query.join(" "), tags.join(", ") ]
  end
end
