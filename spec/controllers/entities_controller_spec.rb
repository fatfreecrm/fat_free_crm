# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe EntitiesController do
  describe "parse_query_and_tags" do
    it "should parse empty string" do
      str = ""
      expect(controller.send(:parse_query_and_tags, str)).to eq(['', ''])
    end

    it "should parse #tags" do
      str = "#test"
      expect(controller.send(:parse_query_and_tags, str)).to eq(['', 'test'])
    end

    it 'should parse #multiword tags' do
      str = "#multiword tag#"
      expect(controller.send(:parse_query_and_tags, str)).to eq(['', 'multiword tag'])
    end

    it "should parse no tags" do
      str = "test query"
      expect(controller.send(:parse_query_and_tags, str)).to eq(['test query', ''])
    end

    it "should parse tags and query" do
      str = "#real Billy Bones #pirate"
      expect(controller.send(:parse_query_and_tags, str)).to eq(["Billy Bones", "real, pirate"])
    end

    it "should parse strange characters" do
      str = "#this is #a test !@$%^~ #parseme"
      expect(controller.send(:parse_query_and_tags, str)).to eq(['is test !@$%^~', 'this, a, parseme'])
    end

    it "should strip whitespace" do
      str = "     test    me    "
      expect(controller.send(:parse_query_and_tags, str)).to eq(['test me', ''])
    end
  end
end
