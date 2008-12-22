class LeadsController < ApplicationController
  before_filter :require_user, :except => [ :toggle ]
  before_filter "set_current_tab(:leads)", :except => [ :toggle ]

  # GET /leads
  # GET /leads.xml
  #----------------------------------------------------------------------------
  def index
    @leads = Lead.find(:all)

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
    @users = User.all_except(@current_user)
    @campaigns = Campaign.find(:all)

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

  # GET /toggle
  #----------------------------------------------------------------------------
  def toggle
    render :update do |page|
      if params[:visible] == "false"
        page["#{params[:id]}_arrow"].replace_html "&#9660;"
        callback = "beforeStart"
      else
        page["#{params[:id]}_arrow"].replace_html "&#9658;"
        callback = "afterFinish"
      end
      page << "Effect.toggle('#{params[:id]}', 'slide', { duration: 0.25, #{callback}: function() { $('#{params[:id]}_intro').toggle(); } });"
    end
  end

end
