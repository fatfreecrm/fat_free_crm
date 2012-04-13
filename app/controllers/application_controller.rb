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

  before_filter :set_context
  before_filter :clear_setting_cache
  before_filter "hook(:app_before_filter, self)"
  after_filter  "hook(:app_after_filter,  self)"

  helper_method :current_user_session, :current_user, :can_signup?
  helper_method :called_from_index_page?, :called_from_landing_page?
  helper_method :klass

  respond_to :html, :only => [ :index, :show, :auto_complete ]
  respond_to :js
  respond_to :json, :xml, :except => :edit
  respond_to :atom, :csv, :rss, :xls, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :respond_to_not_found
  rescue_from CanCan::AccessDenied,         :with => :respond_to_access_denied

  # Common auto_complete handler for all core controllers.
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query] || ''
    @auto_complete = hook(:auto_complete, self, :query => @query, :user => @current_user)
    if @auto_complete.empty?
      @auto_complete = klass.my.text_search(@query).limit(10)
    else
      @auto_complete = @auto_complete.last
    end
    session[:auto_complete] = controller_name.to_sym
    respond_to do |format|
      format.any(:js, :html)   { render :partial => 'auto_complete' }
      format.json { render :json => @auto_complete.inject({}){|h,a| h[a.id] = a.name; h } }
    end
  end

private

  #----------------------------------------------------------------------------
  def klass
    @klass ||= controller_name.classify.constantize
  end

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

  # Proxy current page for any of the controllers by storing it in a session.
  #----------------------------------------------------------------------------
  def current_page=(page)
    @current_page = session[:"#{controller_name}_current_page"] = page.to_i
  end

  #----------------------------------------------------------------------------
  def current_page
    page = params[:page] || session[:"#{controller_name}_current_page"] || 1
    @current_page = page.to_i
  end

  # Proxy current search query for any of the controllers by storing it in a session.
  #----------------------------------------------------------------------------
  def current_query=(query)
    @current_query = session[:"#{controller_name}_current_query"] = query
  end

  #----------------------------------------------------------------------------
  def current_query
    @current_query = params[:query] || session[:"#{controller_name}_current_query"] || ''
  end

  #----------------------------------------------------------------------------
  def asset
    self.controller_name.singularize
  end

  #----------------------------------------------------------------------------
  def respond_to_not_found(*types)
    flash[:warning] = t(:msg_asset_not_available, asset)

    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.js   { render(:update) { |page| page.reload } }
      format.json { render :text => flash[:warning], :status => :not_found }
      format.xml  { render :text => flash[:warning], :status => :not_found }
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_related_not_found(related, *types)
    asset = "note" if asset == "comment"
    flash[:warning] = t(:msg_cant_create_related, :asset => asset, :related => related)

    url = send("#{related.pluralize}_path")
    respond_to do |format|
      format.html { redirect_to url }
      format.js   { render(:update) { |page| page.redirect_to url } }
      format.json { render :text => flash[:warning], :status => :not_found }
      format.xml  { render :text => flash[:warning], :status => :not_found }
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_access_denied
    if self.action_name == "show"
      flash[:warning] = t(:msg_asset_not_authorized, asset)

    else
      flick = case self.action_name
        when "destroy" then "delete"
        when "promote" then "convert"
        else self.action_name
      end
      flash[:warning] = t(:msg_cant_do, :action => flick, :asset => asset)
    end

    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.js   { render(:update) { |page| page.reload } }
      format.json { render :text => flash[:warning], :status => :not_found }
      format.xml  { render :text => flash[:warning], :status => :not_found }
    end
  end
end
