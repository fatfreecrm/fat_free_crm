class HomeController < ApplicationController
  before_filter :require_user, :only => [ :index ]
  before_filter { |filter| filter.send(:set_current_tab, :home) }
  
  #----------------------------------------------------------------------------
  def index
  end
  
end
