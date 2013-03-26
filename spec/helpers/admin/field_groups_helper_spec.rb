# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FieldGroupsHelper do
  it "should return the correct info text about tag restrictions and classes for groups" do
    field_group = FactoryGirl.build(:field_group, :klass_name => "Contact", :label => "Test Field Group")
    html = field_group_subtitle(field_group)
    html.should include("Test Field Group")
    html.should include("This field group applies to contacts tagged with")
    field_group.tag = nil
    field_group.klass_name = "Account"
    field_group_subtitle(field_group).should include("This field group applies to all accounts")
  end
end
