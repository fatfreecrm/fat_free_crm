# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "Lead Import" do
  before do
    do_login(admin: true)
  end

  it "should allow admin to import leads from CSV" do
    visit admin_leads_path

    expect(page).to have_content("Leads Import")

    csv_content = "First Name,Last Name,Email\nImported,Lead,imported@lead.com"
    file = Tempfile.new(['leads', '.csv'])
    file.write(csv_content)
    file.rewind

    attach_file("file", file.path)
    click_button "Import Leads"

    expect(page).to have_content("Successfully imported 1 leads.")

    visit leads_path
    expect(page).to have_content("Imported Lead")
  end
end
