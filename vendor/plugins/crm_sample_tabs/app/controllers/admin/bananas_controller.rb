class Admin::BananasController < Admin::ApplicationController
  unloadable # See http://dev.rubyonrails.org/ticket/6001
  before_filter :set_current_tab
  
  def index
    # render views/admin/bananas/index.html.haml
  end
end
