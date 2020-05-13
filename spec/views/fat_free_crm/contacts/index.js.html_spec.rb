# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/contacts/index" do

    before do
      login
    end

    it "should render [contact] template with @contacts collection if there are contacts" do
      assign(:contacts, [build_stubbed(:contact, id: 42)].paginate)

      render template: 'fat_free_crm/contacts/index', formats: [:js]

      expect(rendered).to include("$('#contacts').html('<li class=\\'brief fat_free_crm_contact highlight\\' id=\\'fat_free_crm_contact_42\\'")
      expect(rendered).to include("#paginate")
    end

    it "should render [empty] template if @contacts collection if there are no contacts" do
      assign(:contacts, [].paginate)

      render template: 'fat_free_crm/contacts/index', formats: [:js]

      expect(rendered).to include("$('#contacts').html('<div id=\\'empty\\'>")
      expect(rendered).to include("#paginate")
    end
  end
end
