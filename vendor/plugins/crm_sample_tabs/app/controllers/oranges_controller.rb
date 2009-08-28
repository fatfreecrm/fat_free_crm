class OrangesController < ApplicationController
  unloadable # See http://dev.rubyonrails.org/ticket/6001
  before_filter :require_user
  before_filter :set_current_tab
  
  def index
    # render views/oranges/index.html.haml
  end
end
