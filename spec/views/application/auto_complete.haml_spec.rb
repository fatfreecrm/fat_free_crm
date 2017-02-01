# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/application/_auto_complete" do
  include AccountsHelper

  before do
    login_and_assign
  end

  [:account, :campaign, :contact, :lead, :opportunity].each do |model|
    it "should render autocomplete list if #{model} matches found" do
      @auto_complete = if model == :lead
                         FactoryGirl.build_stubbed(:lead, first_name: "Billy", last_name: "Bones", company: "Hello, World!")
                       elsif model == :contact
                         FactoryGirl.build_stubbed(:contact, first_name: "Billy", last_name: "Bones")
                       else
                         FactoryGirl.build_stubbed(model, name: "Hello, World!")
      end
      assign(:auto_complete, [@auto_complete])

      render
      expect(rendered).to have_tag("ul", count: 1) do |list|
        if model == :lead
          expect(list).to have_tag("li", id: @auto_complete.id.to_s, text: "#{@auto_complete.name} (#{@auto_complete.company})")
        else
          expect(list).to have_tag("li", id: @auto_complete.id.to_s, text: @auto_complete.name)
        end
      end
    end

    it "should render a message if #{model} doesn't match the query" do
      assign(:query, "Hello")
      assign(:auto_complete, [])

      render
      expect(rendered).to have_tag("ul", count: 1) do |_list|
        with_tag("li", id: nil, count: 1, text: /^No/)
      end
    end
  end
end
