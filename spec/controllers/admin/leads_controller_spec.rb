# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe Admin::LeadsController do
  before do
    login_admin
  end

  describe "GET index" do
    it "assigns the current tab" do
      get :index
      expect(assigns[:current_tab]).to eq("admin/leads")
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "POST import" do
    it "redirects to index if no file is provided" do
      post :import
      expect(flash[:error]).to eq(I18n.t(:msg_no_file_chosen))
      expect(response).to redirect_to(admin_leads_path)
    end

    it "imports leads from a valid CSV file" do
      csv_content = "First Name,Last Name,Email\nJohn,Doe,john@doe.com\nJane,Smith,jane@smith.com"
      file = Tempfile.new(['leads', '.csv'])
      file.write(csv_content)
      file.rewind

      uploaded_file = fixture_file_upload(file.path, 'text/csv')

      expect { post :import, params: { file: uploaded_file } }.to change(Lead, :count).by(2)

      expect(flash[:notice]).to eq(I18n.t(:msg_imported_leads, count: 2))
      expect(response).to redirect_to(admin_leads_path)

      lead = Lead.find_by(email: "john@doe.com")
      expect(lead.first_name).to eq("John")
      expect(lead.last_name).to eq("Doe")
      expect(lead.user).to eq(current_user)
    end

    it "reports errors for invalid records" do
      csv_content = "First Name,Last Name,Email\n,Doe,john@doe.com" # Missing first name
      file = Tempfile.new(['leads', '.csv'])
      file.write(csv_content)
      file.rewind

      uploaded_file = fixture_file_upload(file.path, 'text/csv')

      expect { post :import, params: { file: uploaded_file } }.not_to change(Lead, :count)

      expect(flash[:warning]).to eq(I18n.t(:msg_imported_leads_with_errors, count: 0, errors: 1))
      expect(response).to redirect_to(admin_leads_path)
    end
  end
end
