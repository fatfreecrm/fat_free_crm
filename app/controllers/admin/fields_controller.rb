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

class Admin::FieldsController < Admin::ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter "set_current_tab('admin/fields')", :only => [ :index ]
  before_filter :auto_complete, :only => :auto_complete

  # GET /fields
  # GET /fields.xml                                                      HTML
  #----------------------------------------------------------------------------
  def index
  end

  # GET /fields/1
  # GET /fields/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @custom_field = Field.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @custom_field }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /fields/new
  # GET /fields/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def new
    @field = CustomField.new(:field_group_id => params[:field_group_id])

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @field }
    end

  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_not_found(:html, :xml)
  end

  # GET /fields/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @field = Field.find(params[:id])

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Field.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js)
  end

  # POST /fields
  # POST /fields.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    @field = CustomField.new(params[:field])

    respond_to do |format|
      if @field.save
        format.js   # create.js.rjs
        format.xml  { render :xml => @field, :status => :created, :location => @field }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fields/1
  # PUT /fields/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @field = Field.find(params[:id])

    respond_to do |format|
      if @field.update_attributes(params[:field])
        format.js
        format.xml  { head :ok }
      else
        format.js
        format.xml  { render :xml => @field.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /fields/1
  # DELETE /fields/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def destroy
    @field = CustomField.find(params[:id])

    respond_to do |format|
      if @field.destroy
        format.js   # destroy.js.rjs
        format.xml  { head :ok }
      else
        format.js   # destroy.js.rjs
        format.xml  { render :xml => @field.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # POST /fields/sort
  #----------------------------------------------------------------------------
  def sort
    field_group_id = params[:field_group_id].to_i
    field_ids = params["fields_field_group_#{field_group_id}"] || []

    field_ids.each_with_index do |id, index|
      Field.update_all({:position => index+1, :field_group_id => field_group_id}, {:id => id})
    end

    render :nothing => true
  end

  # POST /fields/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete
end

