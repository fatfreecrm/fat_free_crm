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

class MandrillEmailsController < EntitiesController

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
      format.html do
      end
    end
  end
  
  def mandrill_send
    @mandrill_email = MandrillEmail.find(params[:id])
    @mandrill_email.update_attributes(params[:mandrill_email])
    mandrill = Mailchimp::Mandrill.new(Setting.mandrill[:api_key])
    
    # recipients = @contact_group.contacts.collect{ |c| 
    #         [:email => c.email, :name => c.first_name] unless c.email.blank?
    #       }
    if params[:mandrill_email][:mailing_list] == "TT Email"
      recipients = Contact.where('cf_supporter_emails LIKE (?)', "%TT Email%")
    elsif params[:mandrill_email][:mailing_list] == "Prayer Points"
      recipients = Contact.where('cf_supporter_emails LIKE (?)', "%Prayer Points%")
    end
    recipients_list = recipients.collect{|r| {:email => r.email, :name => r.full_name}}
    recipients = [:email => "reuben.salagaras@gmail.com", :name => "Reuben Salagaras"]
    # response = mandrill.messages_send_template({
    #      :template_name => params[:mandrill_email][:template],
    #      :template_content => [:name => "body_content", :content => params[:mandrill_email][:message_body]],
    #      :message => {
    #        :subject => params[:mandrill_email][:message_subject],
    #        :from_email => params[:mandrill_email][:from_address],
    #        :to => recipients,
    #        :attachments => [{
    #          :type => 'application/pdf', 
    #          :name => @mandrill_email.attached_file_file_name, 
    #          :content => Base64.encode64(open(@mandrill_email.attached_file.path, &:read))}]
    #      }
    #     })
    #     logger.info(response)
    #     if response.is_a?(Hash) && response["status"] == "error"
    #           @mandrill_email.errors.add(:from_address, "Error from MailChimp API: #{response["message"]} (code #{response["code"]})")
    #     end

    if @mandrill_email.errors.empty?
      @mandrill_emails = get_mandrill_emails(:page => params[:page])
      get_data_for_sidebar
      render :index
    else
      mandrill = Mailchimp::Mandrill.new(Setting.mandrill[:api_key])
      list = mandrill.templates_list.map{|a| a.slice("name")}

      @templates_list = list.map{|a| [a["name"],a["name"]]}
      render :show
    end
  end
  
  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @mandrill_email.attributes = {:user => @current_user, :access => Setting.default_access, :assigned_to => nil}
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
