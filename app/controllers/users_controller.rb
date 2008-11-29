class UsersController < ApplicationController

  before_filter :require_no_user, :only => [ :new, :create ]
  before_filter :require_user, :only => [ :show, :edit, :update ]
  
  #----------------------------------------------------------------------------
  def new
    @user = User.new
  end
  
  #----------------------------------------------------------------------------
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfull registration."
      redirect_back_or_default profile_url
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
      redirect_to profile_url
    else
      render :action => :edit
    end
  end

end
