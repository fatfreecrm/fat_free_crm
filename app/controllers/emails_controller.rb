class EmailsController < ApplicationController
  # GET /email
  # GET /email.xml
  def index
    @emails = Email.find(:all)

    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @emails }
    end
  end

  # GET /email/1
  # GET /email/1.xml
  def show
    @email = Email.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @email }
    end
  end

  # GET /email/new
  # GET /email/new.xml
  def new
    @email = Email.new

    respond_to do |format|
      format.html # new.haml
      format.xml  { render :xml => @email }
    end
  end

  # GET /email/1/edit
  def edit
    @email = Email.find(params[:id])
  end

  # POST /email
  # POST /email.xml
  def create
    @email = Email.new(params[:email])

    respond_to do |format|
      if @email.save
        flash[:notice] = 'Email was successfully created.'
        format.html { redirect_to(email_path(@email)) }
        format.xml  { render :xml => @email, :status => :created, :location => @email }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /email/1
  # PUT /email/1.xml
  def update
    @email = Email.find(params[:id])

    respond_to do |format|
      if @email.update_attributes(params[:email])
        flash[:notice] = 'Email was successfully updated.'
        format.html { redirect_to(email_path(@email)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /email/1
  # DELETE /email/1.xml
  def destroy
    @email = Email.find(params[:id])
    @email.destroy

    respond_to do |format|
      format.html { redirect_to(emails_url) }
      format.xml  { head :ok }
    end
  end
end
