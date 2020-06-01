# frozen_string_literal: true

module FatFreeCrm
  module Admin
    class FacilitiesController < EntitiesController
      before_action :setup_current_tab, only: %i[index show]
      # before_action :require_admin_user
      # load_and_authorize_resource :facility
      load_and_authorize_resource :class => "FatFreeCrm::Facility"



      # GET /facilities
      #----------------------------------------------------------------------------
      def index
        @facilities = get_facilities(page: page_param, per_page: per_page_param)

        respond_with @facilities do |format|
          format.xls  { render layout: 'header' }
          format.csv  { render csv: @facilities }
          format.js   { render "/fat_free_crm/facilities/index"}
          format.html { render "/fat_free_crm/facilities/index"}
        end
      end

      # GET /facilities/1
      # AJAX /facilities/1
      #----------------------------------------------------------------------------
      def show
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        respond_with(@facility) do |format|
          format.js   { render "fat_free_crm/facilities/show" }
          format.html { render "fat_free_crm/facilities/show" }
        end
      end

      # GET /facilities/new
      #----------------------------------------------------------------------------
      def new
        @facility.attributes = { user: current_user }
        get_accounts

        if params[:related]
          model, id = params[:related].split('_')
          instance_variable_set("@#{model}", "FatFreeCrm::#{model.classify}".constantize.find(id))
        end

        respond_with(@facility) do |format|
          format.xls { render layout: 'header' }
          format.js  { render "fat_free_crm/facilities/new" }
        end
      end

      # GET /facilities/1/edit                                                   AJAX
      #----------------------------------------------------------------------------
      def edit
        @previous = Facility.my(current_user).find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i if params[:previous].to_s =~ /(\d+)\z/
        get_accounts

        respond_with(@facility) do |format|
          format.js { render "fat_free_crm/facilities/edit" }
        end
      end

      # POST /facilities
      #----------------------------------------------------------------------------
      def create
        get_accounts
        @comment_body = params[:comment_body]
        respond_with(@facility) do |format|
          if @facility.save
            @facility.add_comment_by_user(@comment_body, current_user)
            # None: facility can only be created from the facilities index page, so we
            # don't have to check whether we're on the index page.
            @facilities = get_facilities
          end
          format.js { render "fat_free_crm/facilities/create" }
        end
      end

      # PUT /facilities/1™
      #----------------------------------------------------------------------------
      def update
        respond_with(@facility) do |format|
          # Must set access before user_ids, because user_ids= method depends on access value.
          @facility.access = params[:facility][:access] if params[:facility][:access]
          format.js { render "fat_free_crm/facilities/update" }
        end
      end

      # DELETE /facilities/1
      #----------------------------------------------------------------------------
      def destroy
        @facility.destroy

        respond_with(@facility) do |format|
          format.html { respond_to_destroy(:html) }
          format.js   { respond_to_destroy(:ajax) }
        end
      end

      # PUT /facilities/1/attach
      #----------------------------------------------------------------------------
      # Handled by EntitiesController :attach

      # PUT /facilities/1/discard
      #----------------------------------------------------------------------------
      # Handled by EntitiesController :discard

      # POST /facilities/auto_complete/query                                     AJAX
      #----------------------------------------------------------------------------
      # Handled by ApplicationController :auto_complete

      # GET /facilities/redraw                                                   AJAX
      # ----------------------------------------------------------------------------
      def redraw
        current_user.pref[:facilities_per_page] = per_page_param if per_page_param
        current_user.pref[:facilities_sort_by]  = FatFreeCrm::Facility.sort_by_map[params[:sort_by]] if params[:sort_by]
        @facilities = get_facilities(page: 1, per_page: per_page_param)
        set_options # Refresh options

        respond_with(@facilities) do |format|
          format.js { render :index }
        end
      end

      # POST /facilities/filter                                                  AJAX
      #----------------------------------------------------------------------------
      def filter
        session[:facilities_filter] = params[:category]
        @facilities = get_facilities(page: 1, per_page: per_page_param)

        respond_with(@facilities) do |format|
          format.js { render :index }
        end
      end

      private

      # #----------------------------------------------------------------------------
      alias get_facilities get_list_of_records

      #----------------------------------------------------------------------------
      def list_includes
        %i[user tags].freeze
      end

      #----------------------------------------------------------------------------
      def get_accounts
        @accounts = FatFreeCrm::Account.my(current_user).order('name')
      end

      #----------------------------------------------------------------------------
      def respond_to_destroy(method)
        if method == :ajax
          @facilities = get_facilities
          if @facilities.empty?
            @facilities = get_facilities(page: current_page - 1) if current_page > 1
            render("/fat_free_crm/facilities/index") && return
          end
          # At this point render default destroy.js
        else # :html request
          self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
          flash[:notice] = t(:msg_asset_deleted, @facility.name)
          redirect_to admin_facilities_path
        end
      end

      def setup_current_tab
        set_current_tab('/facilities')
      end
    end
  end
end