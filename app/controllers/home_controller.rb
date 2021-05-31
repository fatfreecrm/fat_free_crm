# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[timezone]
  before_action :set_current_tab, only: :index

  #----------------------------------------------------------------------------
  def index
    @activities = get_activities
    @my_tasks = Task.visible_on_dashboard(current_user).includes(:user, :asset).by_due_at
    @my_opportunities = Opportunity.visible_on_dashboard(current_user).includes(:account, :user, :tags).by_closes_on.by_amount
    @my_accounts = Account.visible_on_dashboard(current_user).includes(:user, :tags).by_name
    respond_with @activities do |format|
      format.xls { render xls: @activities, layout: 'header' }
    end
  end

  # GET /home/options                                                      AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @asset = current_user.pref[:activity_asset] || "all"
      @action = current_user.pref[:activity_event] || "all_events"
      @user = current_user.pref[:activity_user] || "all_users"
      @duration = current_user.pref[:activity_duration] || "two_days"
      @all_users = User.order("first_name, last_name")
    end
  end

  # GET /home/redraw                                                       AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:activity_asset] = params[:asset] if params[:asset]
    current_user.pref[:activity_event] = params[:event] if params[:event]
    current_user.pref[:activity_user] = params[:user] if params[:user]
    current_user.pref[:activity_duration] = params[:duration] if params[:duration]
    @activities = get_activities

    respond_with(@activities) do |format|
      format.js { render :index }
    end
  end

  # GET /home/toggle                                                       AJAX
  #----------------------------------------------------------------------------
  def toggle
    if (toggle_param = params[:id]&.to_sym)
      session[:toggle_states] ||= {}
      if session[:toggle_states][toggle_param]
        session[:toggle_states].delete(toggle_param)
      else
        session[:toggle_states][toggle_param] = true
      end
    end
    head :ok
  end

  # GET /home/timeline                                                     AJAX
  #----------------------------------------------------------------------------
  def timeline
    state = params[:state].to_s
    if %w[Collapsed Expanded].include?(state)
      if (model_type = params[:type].to_s).present?
        if %w[comment email].include?(model_type)
          model = model_type.camelize.constantize
          item = model.find(params[:id])
          item.update_attribute(:state, state)
        end
      else
        comments, emails = params[:id].split("+")
        Comment.where(id: comments.split(',')).update_all(state: state) unless comments.blank?
        Email.where(id: emails.split(',')).update_all(state: state) unless emails.blank?
      end
    end

    head :ok
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
    head :ok
  end

  private

  #----------------------------------------------------------------------------
  def get_activities(options = {})
    options[:asset]    ||= activity_asset
    options[:event]    ||= activity_event
    options[:user]     ||= activity_user
    options[:duration] ||= activity_duration
    options[:max]      ||= 500

    Version.includes(user: [:avatar]).latest(options).visible_to(current_user)
  end

  #----------------------------------------------------------------------------
  def activity_asset
    asset = current_user.pref[:activity_asset]
    if asset.nil? || asset == "all"
      nil
    else
      asset.singularize.capitalize
    end
  end

  #----------------------------------------------------------------------------
  def activity_event
    event = current_user.pref[:activity_event]
    if event == "all_events"
      %w[create update destroy]
    else
      event
    end
  end

  #----------------------------------------------------------------------------
  # TODO: this is ugly, ugly code. It's being security patched now but urgently
  # needs refactoring to use user id instead. Permuations based on name or email
  # yield incorrect results.
  def activity_user
    return nil if current_user.pref[:activity_user] == "all_users"
    return nil unless current_user.pref[:activity_user]

    is_email = current_user.pref[:activity_user].include?("@")

    user = if is_email
             User.where(email: current_user.pref[:activity_user]).first
           else # first_name middle_name last_name any_name
             name_query(current_user.pref[:activity_user])
           end

    user.is_a?(User) ? user.id : nil
  end

  def name_query(user)
    if user.include?(" ")
      user.name_permutations.map do |first, last|
        User.where(first_name: first, last_name: last)
      end.map(&:to_a).flatten.first
    else
      [User.where(first_name: user), User.where(last_name: user)].map(&:to_a).flatten.first
    end
  end

  #----------------------------------------------------------------------------
  def activity_duration
    duration = current_user.pref[:activity_duration]
    if duration
      words = duration.split("_") # "two_weeks" => 2.weeks
      %w[zero one two].index(words.first).send(words.last) if %w[one two].include?(words.first) && %w[hour day days week weeks month].include?(words.last)
    end
  end
end
