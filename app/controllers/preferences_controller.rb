class PreferencesController < ApplicationController
  before_filter :require_user, :set_current_tab
  
  #----------------------------------------------------------------------------
  def index
  end
  
end
