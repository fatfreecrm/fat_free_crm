class LeadsController < ApplicationController
  before_filter :require_user
  before_filter { |filter| filter.send(:set_current_tab, :leads) }

  # GET /leads
  # GET /leads.xml
  #----------------------------------------------------------------------------
  def index
    @leads = Lead.find(:all)
    @status = Setting.lead_status

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leads }
    end
  end

  # GET /leads/1
  # GET /leads/1.xml
  #----------------------------------------------------------------------------
  def show
    @lead = Lead.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/new
  # GET /leads/new.xml
  #----------------------------------------------------------------------------
  def new
    @lead = Lead.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/1/edit
  #----------------------------------------------------------------------------
  def edit
    @lead = Lead.find(params[:id])
  end

  # POST /leads
  # POST /leads.xml
  #----------------------------------------------------------------------------
  def create
    @lead = Lead.new(params[:lead])

    respond_to do |format|
      if @lead.save
        flash[:notice] = 'Lead was successfully created.'
        format.html { redirect_to(@lead) }
        format.xml  { render :xml => @lead, :status => :created, :location => @lead }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1
  # PUT /leads/1.xml
  #----------------------------------------------------------------------------
  def update
    @lead = Lead.find(params[:id])

    respond_to do |format|
      if @lead.update_attributes(params[:lead])
        flash[:notice] = 'Lead was successfully updated.'
        format.html { redirect_to(@lead) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.xml
  #----------------------------------------------------------------------------
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    flash[:notice] = "Lead #{@lead.full_name} was successfully deleted."
    respond_to do |format|
      format.html { redirect_to(leads_url) }
      format.xml  { head :ok }
    end
  end

  # POST /leads/1
  # POST /leads/1.xml
  #----------------------------------------------------------------------------
  def convert
  end

  #----------------------------------------------------------------------------
  def auto_complete_for_lead_assigned_to
    @users = User.find(:all).each do |user|
      user[:full_name] = user.full_name
    end
    render :inline => "<%= auto_complete_result @users, :full_name, params[:lead][:assigned_to] %>"
  end

  #----------------------------------------------------------------------------
  def auto_complete_for_lead_campaign
    @campaigns = Campaign.find(:all)
    render :inline => "<%= auto_complete_result @campaigns, :name, params[:lead][:campaign] %>"
  end

  #----------------------------------------------------------------------------
  def auto_complete_for_lead_status
    @status = Setting.lead_status.values.map { |s| s[:label] }
    render :inline => "<%= '<ul><li>' << @status.join('</li><li>') << '</li></ul>' %>"
  end

end
