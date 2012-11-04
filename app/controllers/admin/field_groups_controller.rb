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

class Admin::FieldGroupsController < Admin::ApplicationController

  helper 'admin/fields'

  # GET /admin/field_groups/new
  # GET /admin/field_groups/new.xml                                        AJAX
  #----------------------------------------------------------------------------
  def new
    @field_group = FieldGroup.new(:klass_name => params[:klass_name])

    respond_with(@field_group)
  end

  # GET /admin/field_groups/1/edit                                         AJAX
  #----------------------------------------------------------------------------
  def edit
    @field_group = FieldGroup.find(params[:id])

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = FieldGroup.find_by_id($1) || $1.to_i
    end

    respond_with(@field_group)
  end

  # POST /admin/field_groups
  # POST /admin/field_groups.xml                                           AJAX
  #----------------------------------------------------------------------------
  def create
    @field_group = FieldGroup.create(params[:field_group])

    respond_with(@field_group)
  end

  # PUT /admin/field_groups/1
  # PUT /admin/field_groups/1.xml                                          AJAX
  #----------------------------------------------------------------------------
  def update
    @field_group = FieldGroup.find(params[:id])
    @field_group.update_attributes(params[:field_group])

    respond_with(@field_group)
  end

  # DELETE /admin/field_groups/1
  # DELETE /admin/field_groups/1.xml                                       AJAX
  #----------------------------------------------------------------------------
  def destroy
    @field_group = FieldGroup.find(params[:id])
    @field_group.destroy

    respond_with(@field_group)
  end

  # POST /admin/field_groups/sort
  #----------------------------------------------------------------------------
  def sort
    asset = params[:asset]
    field_group_ids = params["#{asset}_field_groups"]

    field_group_ids.each_with_index do |id, index|
      FieldGroup.update_all({:position => index+1}, {:id => id})
    end

    render :nothing => true
  end

  # GET /admin/field_groups/1/confirm                                      AJAX
  #----------------------------------------------------------------------------
  def confirm
    @field_group = FieldGroup.find(params[:id])
  end
end
