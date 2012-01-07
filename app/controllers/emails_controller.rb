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

class EmailsController < ApplicationController
  before_filter :require_user

  respond_to :js, :json, :xml

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

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end
end
