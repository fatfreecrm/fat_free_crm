# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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
  # DELETE /emails/1.json
  # DELETE /emails/1.xml                                                   AJAX
  #----------------------------------------------------------------------------
  def destroy
    @email = Email.find(params[:id])
    @email.destroy

    respond_with(@email)
  end
end
