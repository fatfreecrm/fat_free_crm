# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require "fat_free_crm/core_ext/string"

describe "String" do
  it "should generate all possible combinations of first and last name from a query" do
    expected = [
      ["Stephanie", "Man Chi Lo"],
      ["Stephanie Man", "Chi Lo"],
      ["Stephanie Man Chi", "Lo"],
      ["Lo", "Stephanie Man Chi"],
      ["Chi Lo", "Stephanie Man"],
      ["Man Chi Lo", "Stephanie"]
    ]
    result = "Stephanie Man Chi Lo".name_permutations
    expect(result.sort).to eq(expected.sort)
  end
end
