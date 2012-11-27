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
require 'mandrill_email_job'
class MandrillEmailsController < EntitiesController
  before_filter :get_users, :only => [ :new, :create, :edit, :update, :save ]
  before_filter :get_data_for_sidebar, :only => :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    @mandrill_emails = get_mandrill_emails(:page => params[:page])
    
    respond_with @mandrill_emails do |format|
      format.xls { render :layout => 'header' }
    end
  end

  # GET /accounts/1
  #----------------------------------------------------------------------------
  def show
    mandrill = Mailchimp::Mandrill.new(Setting.mandrill[:api_key])
    list = mandrill.templates_list.map{|a| a.slice("name")}
    
    @templates_list = list.map{|a| [a["name"],a["name"]]}
    respond_with(@mandrill_email) do |format|
      @mandrill_email.from_address = @current_user.email
      if !@mandrill_email.attached_files.exists?
        @mandrill_email.attached_files.build
      else
        @attached_file = @mandrill_email.attached_files.first #just dealing with one attachement for now
      end
      format.html do
      end
    end
  end
  
  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @mandrill_email.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}
    @category = Setting.unroll(:mandrill_email_category)
    # if params[:related]
    #       model, id = params[:related].split('_')
    #       if related = model.classify.constantize.my.find_by_id(id)
    #         instance_variable_set("@#{model}", related)
    #       else
    #         respond_to_related_not_found(model) and return
    #       end
    #     end
    
    respond_with(@mandrill_email)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @category = Setting.unroll(:mandrill_email_category)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = MandrillEmail.my.find_by_id($1) || $1.to_i
    end

    respond_with(@mandrill_email)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @mandrill_email = MandrillEmail.new(params[:mandrill_email])
    
    respond_with(@mandrill_email) do |format|
      if @mandrill_email.save_with_permissions(params)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @mandrill_emails = get_mandrill_emails
        get_data_for_sidebar
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@mandrill_email) do |format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @mandrill_email.access = params[:mandrill_email][:access] if params[:mandrill_email][:access]
      if @mandrill_email.update_attributes(params[:mandrill_email])
        get_data_for_sidebar
      else
        @users = User.except(current_user) # Need it to redraw [Edit Account] form.
      end
    end
  end
  
  def save
    if @mandrill_email.update_attributes(params[:mandrill_email])
      if params[:send]
        #remove any previously enqueued jobs
        delayed_job = @mandrill_email.delayed_job_id
        if Delayed::Job.exists?(delayed_job)
          Delayed::Job.find(delayed_job).destroy
        end
        mandrill_send
      end
      @mandrill_emails = get_mandrill_emails(:page => params[:page])
      respond_with(@mandrill_emails) do |format|
        get_data_for_sidebar
        format.html {redirect_to(:mandrill_emails, :notice => "Mandrill email was saved")}
      end
    else
      respond_with(@mandrill_email) do |format|
        mandrill = Mailchimp::Mandrill.new(Setting.mandrill[:api_key])
        list = mandrill.templates_list.map{|a| a.slice("name")}
        @attached_file = AttachedFile.new
        @templates_list = list.map{|a| [a["name"],a["name"]]}
        get_data_for_sidebar
        format.html {render :action => "show"}
      end
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @mandrill_email.destroy

    respond_with(@mandrill_email) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end
  
  # POST /accounts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:mandrill_emails_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:mandrill_emails_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:mandrill_emails_sort_by]  = MandrillEmail::sort_by_map[params[:sort_by]] if params[:sort_by]
    @mandrill_emails = get_mandrill_emails(:page => 1)
    render :index
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:mandrill_emails_filter] = params[:category]
    @mandrill_emails = get_mandrill_emails(:page => 1)
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_mandrill_emails :get_list_of_records

  def mandrill_send
    # logger.info(response)
    #     if response.is_a?(Hash) && response["status"] == "error"
    #           @mandrill_email.errors.add(:from_address, "Error from MailChimp API: #{response["message"]} (code #{response["code"]})")
    #     end
    
    @mandrill_email.update_attribute(:delayed_job_id, Delayed::Job.enqueue(MandrillEmailJob.new(params[:id]), 3, @mandrill_email.scheduled_at) )
    
    #@mandrill_email.save
  end

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def set_options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:mandrill_emails_per_page] || MandrillEmail.per_page
      @outline  = @current_user.pref[:mandrill_emails_outline]  || MandrillEmail.outline
      @sort_by  = @current_user.pref[:mandrill_emails_sort_by]  || MandrillEmail.sort_by
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @mandrill_emails = get_mandrill_emails
      get_data_for_sidebar
      if @mandrill_emails.empty?
        @mandrill_emails = get_mandrill_emails(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @mandrill_email.name)
      redirect_to mandrill_emails_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @mandrill_email_category_total = Hash[
      Setting.mandrill_email_category.map do |key|
        [ key, MandrillEmail.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @mandrill_email_category_total.values.sum
    @mandrill_email_category_total[:all] = MandrillEmail.my.count
    @mandrill_email_category_total[:other] = @mandrill_email_category_total[:all] - categorized
  end
  
end
