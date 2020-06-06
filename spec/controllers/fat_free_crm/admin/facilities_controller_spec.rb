# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'
require 'pry'

module FatFreeCrm::Admin
  describe FacilitiesController do
    routes { FatFreeCrm::Engine.routes }

    before do
      login
      current_user.update_attributes(admin: true)
      set_current_tab('/facilities')
    end

    # GET /facilities
    # GET /facilities.xml
    #----------------------------------------------------------------------------
    describe "responding to GET index" do
      it "should expose all facilities as @facilities and render [index] template" do
        @facilities = [create(:facility, user: current_user)]
        get :index
        expect(assigns[:facilities]).to eq(@facilities)
        expect(response).to render_template("facilities/index")
      end

      describe "AJAX pagination" do
        it "should pick up page number from params" do
          @facilities = [create(:facility, user: current_user)]
          get :index, params: { page: 42 }, xhr: true

          expect(assigns[:current_page].to_i).to eq(42)
          expect(assigns[:facilities]).to eq([]) # page #42 should be empty if there's only one facility ;-)
          expect(session[:facilities_current_page].to_i).to eq(42)
          expect(response).to render_template("facilities/index")
        end

        it "should pick up saved page number from session" do
          session[:facilities_current_page] = 42
          @facilities = [create(:facility, user: current_user)]
          get :index, xhr: true

          expect(assigns[:current_page]).to eq(42)
          expect(assigns[:facilities]).to eq([])
          expect(response).to render_template("facilities/index")
        end

        it "should reset current_page when query is altered" do
          session[:facilities_current_page] = 42
          session[:facilities_current_query] = "bill"
          @facilities = [create(:facility, user: current_user)]
          get :index, xhr: true

          expect(assigns[:current_page]).to eq(1)
          expect(assigns[:facilities]).to eq(@facilities)
          expect(response).to render_template("facilities/index")
        end
      end

      describe "with mime type of JSON" do
        it "should render all facilities as json" do
          expect(@controller).to receive(:get_facilities).and_return(facilities = double("Array of facilities"))
          expect(facilities).to receive(:to_json).and_return("generated JSON")

          request.env["HTTP_ACCEPT"] = "application/json"
          get :index
          expect(response.body).to eq("generated JSON")
        end
      end

      describe "with mime type of XML" do
        it "should render all facilities as xml" do
          expect(@controller).to receive(:get_facilities).and_return(facilities = double("Array of facilities"))
          expect(facilities).to receive(:to_xml).and_return("generated XML")

          request.env["HTTP_ACCEPT"] = "application/xml"
          get :index
          expect(response.body).to eq("generated XML")
        end
      end
    end

    # GET /facilities/1
    # GET /facilities/1.xml                                                    HTML
    #----------------------------------------------------------------------------
    describe "responding to GET show" do
      describe "with mime type of HTML" do
        before do
          @facility = create(:facility, user: current_user)
          @stage = Setting.unroll(:opportunity_stage)
          @comment = FatFreeCrm::Comment.new
        end

        it "should expose the requested facility as @facility and render [show] template" do
          get :show, params: { id: @facility.id }
          expect(assigns[:facility]).to eq(@facility)
          expect(assigns[:stage]).to eq(@stage)
          expect(assigns[:comment].attributes).to eq(@comment.attributes)
          expect(response).to render_template("facilities/show")
        end

        it "should update an activity when viewing the facility" do
          get :show, params: { id: @facility.id }
          expect(@facility.versions.last.event).to eq('view')
        end
      end

      describe "with mime type of JSON" do
        it "should render the requested facility as json" do
          @facility = create(:facility, user: current_user)
          expect(FatFreeCrm::Facility).to receive(:find).and_return(@facility)
          expect(@facility).to receive(:to_json).and_return("generated JSON")

          request.env["HTTP_ACCEPT"] = "application/json"
          get :show, params: { id: 42 }
          expect(response.body).to eq("generated JSON")
        end
      end

      describe "with mime type of XML" do
        it "should render the requested facility as xml" do
          @facility = create(:facility, user: current_user)
          expect(FatFreeCrm::Facility).to receive(:find).and_return(@facility)
          expect(@facility).to receive(:to_xml).and_return("generated XML")

          request.env["HTTP_ACCEPT"] = "application/xml"
          get :show, params: { id: 42 }
          expect(response.body).to eq("generated XML")
        end
      end

      describe "facility got deleted or otherwise unavailable" do
        it "should redirect to facility index if the facility got deleted" do
          @facility = create(:facility, user: current_user)
          @facility.destroy

          get :show, params: { id: @facility.id }
          expect(flash[:warning]).not_to eq(nil)
          expect(response).to redirect_to(admin_facilities_path)
        end

        it "should redirect to facility index if the facility is protected" do
          @private = create(:facility, user: create(:user), access: "Private")

          get :show, params: { id: @private.id }
          expect(response.successful?).to eql(true)
        end

        it "should return 404 (Not Found) JSON error" do
          @facility = create(:facility, user: current_user)
          @facility.destroy
          request.env["HTTP_ACCEPT"] = "application/json"

          get :show, params: { id: @facility.id }
          expect(response.code).to eq("404") # :not_found
        end

        it "should return 404 (Not Found) XML error" do
          @facility = create(:facility, user: current_user)
          @facility.destroy
          request.env["HTTP_ACCEPT"] = "application/xml"

          get :show, params: { id: @facility.id }
          expect(response.code).to eq("404") # :not_found
        end
      end
    end

    # GET /facilities/new
    # GET /facilities/new.xml                                                  AJAX
    #----------------------------------------------------------------------------
    describe "responding to GET new" do
      it "should expose a new facility as @facility and render [new] template" do
        @facility = FatFreeCrm::Facility.new(user: current_user,
                               access: Setting.default_access)
        get :new, xhr: true
        expect(assigns[:facility].attributes).to eq(@facility.attributes)
        expect(assigns[:contact]).to eq(nil)
        expect(response).to render_template("facilities/new")
      end

      it "should created an instance of related object when necessary" do
        @contact = create(:contact, id: 42)

        get :new, params: { related: "contact_42" }, xhr: true
        expect(assigns[:contact]).to eq(@contact)
      end
    end

    # GET /facilities/1/edit                                                   AJAX
    #----------------------------------------------------------------------------
    describe "responding to GET edit" do
      it "should expose the requested facility as @facility and render [edit] template" do
        @facility = create(:facility, id: 42, user: current_user)

        get :edit, params: { id: 42 }, xhr: true
        expect(assigns[:facility]).to eq(@facility)
        expect(assigns[:previous]).to eq(nil)
        expect(response).to render_template("facilities/edit")
      end

      it "should expose previous facility as @previous when necessary" do
        @facility = create(:facility, id: 42)
        @previous = create(:facility, id: 41)

        get :edit, params: { id: 42, previous: 41 }, xhr: true
        expect(assigns[:previous]).to eq(@previous)
      end

      describe "(facility got deleted or is otherwise unavailable)" do
        it "should reload current page with the flash message if the facility got deleted" do
          @facility = create(:facility, user: current_user)
          @facility.destroy

          get :edit, params: { id: @facility.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end

      describe "(previous facility got deleted or is otherwise unavailable)" do
        before do
          @facility = create(:facility, user: current_user)
          @previous = create(:facility, user: create(:user))
        end

        it "should notify the view if previous facility got deleted" do
          @previous.destroy

          get :edit, params: { id: @facility.id, previous: @previous.id }, xhr: true
          expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
          expect(assigns[:previous]).to eq(@previous.id)
          expect(response).to render_template("facilities/edit")
        end

        it "should notify the view if previous facility got protected" do
          @previous.update_attribute(:access, "Private")

          get :edit, params: { id: @facility.id, previous: @previous.id }, xhr: true
          expect(flash[:warning]).to eq(nil)
          expect(assigns[:previous].id).to eq(@previous.id)
          expect(response).to render_template("facilities/edit")
        end
      end
    end

    # POST /facilities
    # POST /facilities.xml                                                     AJAX
    #----------------------------------------------------------------------------
    describe "responding to POST create" do
      describe "with valid params" do
        it "should expose a newly created facility as @facility and render [create] template" do
          @facility = build(:facility, name: "Hello world", user: current_user)
          allow(FatFreeCrm::Facility).to receive(:new).and_return(@facility)

          post :create, params: { facility: { name: "Hello world" } }, xhr: true
          expect(assigns(:facility)).to eq(@facility)
          expect(response).to render_template("facilities/create")
        end

        # Note: [Create facility] is shown only on facilities index page.
        it "should reload facilities to update pagination" do
          @facility = build(:facility, user: current_user)
          allow(FatFreeCrm::Facility).to receive(:new).and_return(@facility)

          post :create, params: { facility: { name: "Hello" } }, xhr: true
          expect(assigns[:facilities]).to eq([@facility])
        end
      end

      describe "with invalid params" do
        it "should expose a newly created but unsaved facility as @facility and still render [create] template" do
          @facility = build(:facility, name: nil, user: nil)
          allow(FatFreeCrm::Facility).to receive(:new).and_return(@facility)

          post :create, params: { facility: {} }, xhr: true
          expect(assigns(:facility)).to eq(@facility)
          expect(response).to render_template("facilities/create")
        end
      end
    end

    # PUT /facilities/1
    # PUT /facilities/1.xml                                                    AJAX
    #----------------------------------------------------------------------------
    describe "responding to PUT update" do
      describe "with valid params" do
        it "should update the requested facility, expose the requested facility as @facility, and render [update] template" do
          @facility = create(:facility, id: 42, name: "Hello people")

          put :update, params: { id: 42, facility: { name: "Hello world" } }, xhr: true
          expect(@facility.reload.name).to eq("Hello world")
          expect(assigns(:facility)).to eq(@facility)
          expect(response).to render_template("facilities/update")
        end

        it "should get data for facilities sidebar when called from Campaigns index" do
          @facility = create(:facility, id: 42)
          request.env["HTTP_REFERER"] = "http://localhost/facilities"

          put :update, params: { id: 42, facility: { name: "Hello" } }, xhr: true
          expect(assigns(:facility)).to eq(@facility)
        end

        describe "facility got deleted or otherwise unavailable" do
          it "should reload current page is the facility got deleted" do
            @facility = create(:facility, user: current_user)
            @facility.destroy

            put :update, params: { id: @facility.id }, xhr: true
            expect(flash[:warning]).not_to eq(nil)
            expect(response.body).to eq("window.location.reload();")
          end
        end
      end

      describe "with invalid params" do
        it "should not update the requested facility but still expose the requested facility as @facility, and render [update] template" do
          @facility = create(:facility, id: 42, name: "Hello people")

          put :update, params: { id: 42, facility: { name: nil } }, xhr: true
          expect(assigns(:facility).reload.name).to eq("Hello people")
          expect(assigns(:facility)).to eq(@facility)
          expect(response).to render_template("facilities/update")
        end
      end
    end

    # DELETE /facilities/1
    # DELETE /facilities/1.xml
    #----------------------------------------------------------------------------
    describe "responding to DELETE destroy" do
      before do
        @facility = create(:facility, user: current_user)
      end

      describe "AJAX request" do
        it "should destroy the requested facility and render [destroy] template" do
          @another_facility = create(:facility, user: current_user)
          delete :destroy, params: { id: @facility.id }, xhr: true

          expect { FatFreeCrm::Facility.find(@facility.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect(assigns[:facilities]).to eq([@another_facility]) # @facility got deleted
        end

        it "should try previous page and render index action if current page has no facilities" do
          session[:facilities_current_page] = 42

          delete :destroy, params: { id: @facility.id }, xhr: true
          expect(session[:facilities_current_page]).to eq(41)
          expect(response).to render_template("facilities/index")
        end

        it "should render index action when deleting last facility" do
          session[:facilities_current_page] = 1

          delete :destroy, params: { id: @facility.id }, xhr: true
          expect(session[:facilities_current_page]).to eq(1)
          expect(response).to render_template("facilities/index")
        end

        describe "facility got deleted or otherwise unavailable" do
          it "should reload current page is the facility got deleted" do
            @facility = create(:facility, user: current_user)
            @facility.destroy

            delete :destroy, params: { id: @facility.id }, xhr: true
            expect(response.body).to eq("window.location.reload();")
          end
        end
      end

      describe "HTML request" do
        it "should redirect to facilities index when an facility gets deleted from its landing page" do
          delete :destroy, params: { id: @facility.id }

          expect(flash[:notice]).not_to eq(nil)
          expect(response).to redirect_to(admin_facilities_path)
        end

        it "should redirect to facility index with the flash message is the facility got deleted" do
          @facility = create(:facility, user: current_user)
          @facility.destroy

          delete :destroy, params: { id: @facility.id }
          expect(flash[:warning]).not_to eq(nil)
          expect(response).to redirect_to(admin_facilities_path)
        end

        it "should redirect to facility index with the flash message if the facility is protected" do
          @private = create(:facility, user: create(:user), access: "Private")

          delete :destroy, params: { id: @private.id }
          expect(response).to redirect_to(admin_facilities_path)
        end
      end
    end
  end
end
