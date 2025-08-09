# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe List do
  it "should parse the controller from the url" do
    ["/controller/action", "controller/action?utf8=%E2%9C%93"].each do |url|
      list = build(:list, url: url)
      expect(list.controller).to eq("controller")
    end
    list = build(:list, url: nil)
    expect(list.controller).to eq(nil)
  end
end
