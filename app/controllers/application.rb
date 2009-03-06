class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  before_filter "hook(:app_before_filter, self)"
  after_filter "hook(:app_after_filter, self)"

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => '165eb65bfdacf95923dad9aea10cc64a'

  private
  #----------------------------------------------------------------------------
  def set_current_tab(tab = :none)
    session[:current_tab] = tab
  end
  
  #----------------------------------------------------------------------------
  def current_user_session
    @current_user_session ||= Authentication.find
  end
  
  #----------------------------------------------------------------------------
  def current_user
    @current_user ||= (current_user_session && current_user_session.record)
  end
  
  #----------------------------------------------------------------------------
  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page." if request.request_uri != "/"
      redirect_to login_url
      return false
    end
  end

  #----------------------------------------------------------------------------
  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page."
      redirect_to profile_url
      return false
    end
  end
  
  #----------------------------------------------------------------------------
  def store_location
    session[:return_to] = request.request_uri
  end
  
  #----------------------------------------------------------------------------
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  #----------------------------------------------------------------------------
  def preserve_visibility(name)
    @context = (params[:context].blank? ? name : params[:context].intern)
    session[@context] = (params[:visible] == "true" ? nil : true)
  end

  #----------------------------------------------------------------------------
  def save_context(name)
    session[context = name.to_sym] = (params[:visible] == "true" ? nil : true)
    context
  end

  #----------------------------------------------------------------------------
  def drop_visibility(name)
    session[name] = nil
  end
  alias :drop_context :drop_visibility

  #----------------------------------------------------------------------------
  def visible?(name)
    session[name]
  end
  alias :context_exists? :visible?

  #----------------------------------------------------------------------------
  def find_related_asset_for(model)
    context = @context.to_s
    return if context !~ /\d+$/

    parent, id = context.split("_")[-2, 2]
    if parent.pluralize != parent
      # One-to-one or one-to-many -- assign found object instance to the model.
      model.send("#{parent}=", @asset = parent.capitalize.constantize.find(id))
    else
      # Many-to-many -- find the instance but don't assign it.
      parent = parent.singularize
      @asset = parent.capitalize.constantize.find(id)
    end
    instance_variable_set("@#{parent}", @asset)
  end

end
