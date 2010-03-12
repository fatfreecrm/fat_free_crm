class EmailsController < ApplicationController
  before_filter :require_user
  
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

  # GET /emails/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @email = Email.find(params[:id])

    if @email.mediator
      @email.mediator_type.constantize.my(@current_user).find(@email.mediator.id)
    else
      raise ActiveRecord::RecordNotFound
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # PUT /emails/1
  # PUT /emails/1.xml                                                      AJAX
  #----------------------------------------------------------------------------
  def update
    @email = Email.find(params[:id])

    respond_to do |format|
      if @email.update_attributes(params[:email])
        format.js
        format.xml  { head :ok }
      else
        format.js
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /emails/1
  # DELETE /emails/1.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def destroy
    @email = Email.find(params[:id])

    respond_to do |format|
      if @email.destroy
        format.js   # destroy.js.rjs
        format.xml  { render :xml => @email, :status => :deleted, :location => @email }
      else
        format.js   # destroy.js.rjs
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)    
  end
  
end
