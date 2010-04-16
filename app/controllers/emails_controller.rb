class EmailsController < ApplicationController
  before_filter :require_user
  
  # GET /email
  # GET /email.xml                                              not implemented
  #----------------------------------------------------------------------------
  # def index
  # end

  # GET /email/1
  # GET /email/1.xml                                            not implemented
  #----------------------------------------------------------------------------
  # def show
  # end

  # GET /emails/new
  # GET /emails/new.xml                                         not implemented
  #----------------------------------------------------------------------------
  # def new
  # end

  # GET /emails/1/edit                                          not implemented
  #----------------------------------------------------------------------------
  # def edit
  # end

  # PUT /emails/1
  # PUT /emails/1.xml                                           not implemented
  #----------------------------------------------------------------------------
  # def update
  # end

  # DELETE /emails/1
  # DELETE /emails/1.xml                                                   AJAX
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
