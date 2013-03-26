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
      controller.send(:parse_query_and_tags, str).should == ['', '']
    end
  
    it "should parse #tags" do
      str = "#test"
      controller.send(:parse_query_and_tags, str).should == ['', 'test']
    end
    
    it "should parse no tags" do
      str = "test query"
      controller.send(:parse_query_and_tags, str).should == ['test query', '']
    end
    
    it "should parse tags and query" do
      str = "#real Billy Bones #pirate"
      controller.send(:parse_query_and_tags, str).should == [ "Billy Bones", "real, pirate" ]
    end

    it "should parse strange characters" do
      str = "#this is #a test !@$%^~ #parseme"
      controller.send(:parse_query_and_tags, str).should == ['is test !@$%^~', 'this, a, parseme']
    end
    
    it "should strip whitespace" do
      str = "     test    me    "
      controller.send(:parse_query_and_tags, str).should == ['test me', '']
    end

  end

end
