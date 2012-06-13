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

class Admin::TagsController < Admin::ApplicationController
  before_filter "set_current_tab('admin/tags')", :only => [ :index, :show ]

  load_resource

  # GET /admin/tags
  # GET /admin/tags.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @tags = Tag.all
    respond_with(@tags)
  end

  # GET /admin/tags/new
  # GET /admin/tags/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  def new
    respond_with(@tag)
  end

  # GET /admin/tags/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Tag.find_by_id($1) || $1.to_i
    end
  end

  # POST /admin/tags
  # POST /admin/tags.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    @tag.update_attributes(params[:tag])

    respond_with(@tag)
  end

  # PUT /admin/tags/1
  # PUT /admin/tags/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    @tag.update_attributes(params[:tag])

    respond_with(@tag)
  end

  # DELETE /admin/tags/1
  # DELETE /admin/tags/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    @tag.destroy

    respond_with(@tag)
  end

  # GET /admin/tags/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
  end
end
