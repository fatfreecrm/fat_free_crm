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

class HomeController < ApplicationController
  before_filter :require_user, :except => [ :toggle, :timezone ]
  before_filter :set_current_tab, :only => :index
  before_filter "hook(:home_before_filter, self, :amazing => true)"

  #----------------------------------------------------------------------------
  def index
    @hello = "Hello world" # The hook below can access controller's instance variables.
    hook(:home_controller, self, :params => "it works!")

    @activities = get_activities
    respond_with(@activities)
  end

  # GET /home/options                                                      AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @asset = @current_user.pref[:activity_asset] || "all"
      @action = @current_user.pref[:activity_event] || "all_events"
      @user = @current_user.pref[:activity_user] || "all_users"
      @duration = @current_user.pref[:activity_duration] || "two_days"
      @all_users = User.order("first_name, last_name")
    end
  end

  # POST /home/redraw                                                      AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:activity_asset] = params[:asset] if params[:asset]
    @current_user.pref[:activity_event] = params[:event] if params[:event]
    @current_user.pref[:activity_user] = params[:user] if params[:user]
    @current_user.pref[:activity_duration] = params[:duration] if params[:duration]

    @activities = get_activities
    render :index
  end

  # GET /home/toggle                                                       AJAX
  #----------------------------------------------------------------------------
  def toggle
    if session[params[:id].to_sym]
      session.delete(params[:id].to_sym)
    else
      session[params[:id].to_sym] = true
    end
    render :nothing => true
  end

  # GET /home/timeline                                                     AJAX
  #----------------------------------------------------------------------------
  def timeline
    unless params[:type].empty?
      model = params[:type].camelize.constantize
      item = model.find(params[:id])
      item.update_attribute(:state, params[:state])
    else
      comments, emails = params[:id].split("+")
      Comment.update_all("state = '#{params[:state]}'", "id IN (#{comments})") unless comments.blank?
      Email.update_all("state = '#{params[:state]}'", "id IN (#{emails})") unless emails.blank?
    end

    render :nothing => true
  end

  # GET /home/timezone                                                     AJAX
  #----------------------------------------------------------------------------
  def timezone
    #
    # (new Date()).getTimezoneOffset() in JavaScript returns (UTC - localtime) in
    # minutes, while ActiveSupport::TimeZone expects (localtime - UTC) in seconds.
    #
    if params[:offset]
      session[:timezone_offset] = params[:offset].to_i * -60
      ActiveSupport::TimeZone[session[:timezone_offset]]
    end
    render :nothing => true
  end

  private
  #----------------------------------------------------------------------------
  def get_activities(options = {})
    options[:asset]    ||= activity_asset
    options[:event]    ||= activity_event
    options[:user]     ||= activity_user
    options[:duration] ||= activity_duration

    Version.latest(options).visible_to(@current_user)
  end

  #----------------------------------------------------------------------------
  def activity_asset
    asset = @current_user.pref[:activity_asset]
    if asset.nil? || asset == "all"
      nil
    else
      asset.singularize.capitalize
    end
  end

  #----------------------------------------------------------------------------
  def activity_event
    event = @current_user.pref[:activity_event]
    if event == "all_events"
      %w(create update destroy)
    else
      event
    end
  end

  #----------------------------------------------------------------------------
  def activity_user
    user = @current_user.pref[:activity_user]
    if user && user != "all_users"
      user = if user =~ /@/ # email
          User.where(:email => user).first
        else # first_name middle_name last_name any_name
          name_query = if user.include?(" ")
            user.name_permutations.map{ |first, last|
              "(upper(first_name) LIKE upper('%#{first}%') AND upper(last_name) LIKE upper('%#{last}%'))"
            }.join(" OR ")
          else
            "upper(first_name) LIKE upper('%#{user}%') OR upper(last_name) LIKE upper('%#{user}%')"
          end
          User.where(name_query).first
        end
    end
    user.is_a?(User) ? user.id : nil
  end

  #----------------------------------------------------------------------------
  def activity_duration
    duration = @current_user.pref[:activity_duration]
    if duration
      words = duration.split("_") # "two_weeks" => 2.weeks
      if %w(one two).include?(words.first)
        %w(zero one two).index(words.first).send(words.last)
      end
    end
  end

end
