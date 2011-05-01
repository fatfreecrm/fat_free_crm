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

class AccountsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  # GET /accounts
  # GET /accounts.xml                                             HTML and AJAX
  #----------------------------------------------------------------------------
  def index
    @accounts = get_accounts(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @accounts }
      format.xls  { send_data @accounts.to_xls, :type => :xls }
      format.csv  { send_data @accounts.to_csv, :type => :csv }
      format.rss  { render "common/index.rss.builder" }
      format.atom { render "common/index.atom.builder" }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @account = Account.my.find(params[:id])
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new

    @timeline = Timeline.find(@account)

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @account }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /accounts/new
  # GET /accounts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @account = Account.new(:user => @current_user, :access => Setting.default_access)
    @users = User.except(@current_user)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @account = Account.my.find(params[:id])
    @users = User.except(@current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @account
  end

  # POST /accounts
  # POST /accounts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @account = Account.new(params[:account])
    @users = User.except(@current_user)

    respond_to do |format|
      if @account.save_with_permissions(params[:users])
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @accounts = get_accounts
        get_data_for_sidebar
        format.js   # create.js.rjs
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @account = Account.my.find(params[:id])

    respond_to do |format|
      if @account.update_with_permissions(params[:account], params[:users])
        get_data_for_sidebar
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user) # Need it to redraw [Edit Account] form.
        format.js
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @account = Account.my.find(params[:id])
    @account.destroy if @account

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /accounts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @accounts = get_accounts(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :index }
      format.xml  { render :xml => @accounts.to_xml }
    end
  end

  # PUT /accounts/1/attach
  # PUT /accounts/1/attach.xml                                             AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :attach

  # PUT /accounts/1/discard
  # PUT /accounts/1/discard.xml                                            AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:accounts_per_page] || Account.per_page
      @outline  = @current_user.pref[:accounts_outline]  || Account.outline
      @sort_by  = @current_user.pref[:accounts_sort_by]  || Account.sort_by
    end
  end

  # POST /accounts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:accounts_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:accounts_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:accounts_sort_by]  = Account::sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(:page => 1)
    render :index
  end

  # GET /accounts/contacts                                                 AJAX
  #----------------------------------------------------------------------------
  def contacts
    @account = Account.my.find(params[:id])
  end

  # GET /accounts/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
    @account = Account.my.find(params[:id])
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_account_category] = params[:category]
    @accounts = get_accounts(:page => 1)
    render :index
  end

  private
  #----------------------------------------------------------------------------
  def get_accounts(options = {})
    get_list_of_records(Account, options.merge!(:filter => :filter_by_account_category))
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      get_data_for_sidebar
      if @accounts.blank?
        @accounts = get_accounts(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = "#{t(:asset_deleted, @account.name)}"
      redirect_to accounts_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = Hash[
      Setting.account_category.map do |key|
        [ key, Account.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my.count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end

