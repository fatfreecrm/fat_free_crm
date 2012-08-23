# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

require 'spec_helper'

describe CustomFieldDatePair do

  describe "render_value" do
  
    before(:each) do
      @from = CustomFieldDatePair.new(:name => 'cf_event_from')
      @to = CustomFieldDatePair.new(:name => 'cf_event_to')
      @from.stub!(:paired_with).and_return(@to)
      @today = Date.today
      @today_str = @today.strftime(I18n.t("date.formats.mmddyy"))
    end
  
    it "should be from..." do
      foo = mock(:cf_event_from => @today, :cf_event_to => nil)
      @from.render_value(foo).should == "From #{@today_str}"
    end
    
    it "should be until..." do
      foo = mock(:cf_event_from => nil, :cf_event_to => @today)
      @from.render_value(foo).should == "Until #{@today_str}"
    end
    
    it "should be from ... to" do
      foo = mock(:cf_event_from => @today, :cf_event_to => @today)
      @from.render_value(foo).should == "From #{@today_str} to #{@today_str}"
    end
    
    it "should be empty string" do
      foo = mock(:cf_event_from => nil, :cf_event_to => nil)
      @from.render_value(foo).should == ""
    end

  end

  describe "custom_validator" do

    before(:each) do
      @from = CustomFieldDatePair.new(:name => 'cf_event_from')
      @to = CustomFieldDatePair.new(:name => 'cf_event_to', :pair_id => 1)
      CustomFieldPair.stub!(:find).and_return(@from)
      @today = Date.today
      @today_str = @today.strftime(I18n.t("date.formats.mmddyy"))
    end
  
    it "when from is nil it should be valid" do
      foo = mock(:cf_event_from => nil, :cf_event_to => @today)
      foo.should_not_receive(:errors)
      @to.custom_validator(foo)
    end

    it "when to is nil it should be valid" do
      foo = mock(:cf_event_from => @today, :cf_event_to => nil)
      foo.should_not_receive(:errors)
      @to.custom_validator(foo)
    end
    
    it "when from <= to it should be valid" do
      foo = mock(:cf_event_from => @today, :cf_event_to => @today)
      foo.should_not_receive(:errors)
      @to.custom_validator(foo)
    end
    
    it "when from > to it should not be valid" do
      foo = mock(:cf_event_from => @today, :cf_event_to => @today - 1.day)
      err = mock(:errors); err.stub(:add)
      foo.should_receive(:errors).and_return(err)
      @to.custom_validator(foo)
    end
    
    it "should ignore validation when called on from" do
      foo = mock(:cf_event_from => @today, :cf_event_to => @today - 1.day)
      foo.should_not_receive(:errors)
      CustomFieldPair.should_not_receive(:find)
      @from.custom_validator(foo)
    end

    it "should call custom field validation on super class" do
      from = CustomFieldDatePair.new(:name => 'cf_event_from', :required => true)
      foo = mock(:cf_event_from => nil)
      err = mock(:errors); err.stub(:add)
      foo.should_receive(:errors).and_return(err)
      from.custom_validator(foo)
    end

  end

end
