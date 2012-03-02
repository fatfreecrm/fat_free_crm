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

  # GET /admin/tags
  # GET /admin/tags.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => Tag.all }
      format.xls  { send_data @tags.to_xls, :type => :xls }
      format.csv  { send_data @tags.to_csv, :type => :csv }
      format.rss  { render "shared/index.rss.builder" }
      format.atom { render "shared/index.atom.builder" }
    end
  end

  # GET /admin/tags/new
  # GET /admin/tags/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  def new
    @tag = Tag.new

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @tag }
    end
  end

  # GET /admin/tags/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  def edit
    @tag = Tag.find(params[:id])

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Tag.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @tag
  end

  # POST /admin/tags
  # POST /admin/tags.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        @tags = Tag.all
        format.js   # create.js.rjs
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/tags/1
  # PUT /admin/tags/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.js   # update.js.rjs
        format.xml  { head :ok }
      else
        format.js   # update.js.rjs
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end


  # DELETE /admin/tags/1
  # DELETE /admin/tags/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.destroy
        format.js   # destroy.js.rjs
        format.xml  { head :ok }
      else
        flash[:warning] = t(:msg_cant_delete_tag, @tag.name)
        format.js   # destroy.js.rjs
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /admin/tags/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
    @tag = Tag.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

end

