class UsersController < ApplicationController

  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :require_user, :except => [ :new, :create ]

  #----------------------------------------------------------------------------
  def index
  end

  #----------------------------------------------------------------------------
  def new
    @user = User.new
  end
  
  #----------------------------------------------------------------------------
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfull signup, welcome to Fat Free CRM!"
      redirect_back_or_default preferences_url
    else
      render :action => :new
    end
  end
  
  #----------------------------------------------------------------------------
  def show
    @user = @current_user
  end

  #----------------------------------------------------------------------------
  def edit
    @user = @current_user
  end
  
  #----------------------------------------------------------------------------
  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your user profile has been updated."
      redirect_to preferences_url
    else
      render :action => :edit
    end
  end

end
