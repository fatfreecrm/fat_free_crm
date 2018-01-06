# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe CustomFieldDatePair do
  describe "render_value" do
    before(:each) do
      @from = CustomFieldDatePair.new(name: 'cf_event_from')
      @to = CustomFieldDatePair.new(name: 'cf_event_to')
      allow(@from).to receive(:paired_with).and_return(@to)
      @today = Date.today
      @today_str = @today.strftime(I18n.t("date.formats.mmddyy"))
    end

    it "should be from..." do
      foo = double(cf_event_from: @today, cf_event_to: nil)
      expect(@from.render_value(foo)).to eq("From #{@today_str}")
    end

    it "should be until..." do
      foo = double(cf_event_from: nil, cf_event_to: @today)
      expect(@from.render_value(foo)).to eq("Until #{@today_str}")
    end

    it "should be from ... to" do
      foo = double(cf_event_from: @today, cf_event_to: @today)
      expect(@from.render_value(foo)).to eq("From #{@today_str} to #{@today_str}")
    end

    it "should be empty string" do
      foo = double(cf_event_from: nil, cf_event_to: nil)
      expect(@from.render_value(foo)).to eq("")
    end
  end

  describe "custom_validator" do
    before(:each) do
      @from = CustomFieldDatePair.new(name: 'cf_event_from')
      @to = CustomFieldDatePair.new(name: 'cf_event_to', pair_id: 1)
      allow(CustomFieldPair).to receive(:find).and_return(@from)
      @today = Date.today
      @today_str = @today.strftime(I18n.t("date.formats.mmddyy"))
    end

    it "when from is nil it should be valid" do
      foo = double(cf_event_from: nil, cf_event_to: @today)
      expect(foo).not_to receive(:errors)
      @to.custom_validator(foo)
    end

    it "when to is nil it should be valid" do
      foo = double(cf_event_from: @today, cf_event_to: nil)
      expect(foo).not_to receive(:errors)
      @to.custom_validator(foo)
    end

    it "when from <= to it should be valid" do
      foo = double(cf_event_from: @today, cf_event_to: @today)
      expect(foo).not_to receive(:errors)
      @to.custom_validator(foo)
    end

    it "when from > to it should not be valid" do
      foo = double(cf_event_from: @today, cf_event_to: @today - 1.day)
      err = double(:errors); allow(err).to receive(:add)
      expect(foo).to receive(:errors).and_return(err)
      @to.custom_validator(foo)
    end

    it "should ignore validation when called on from" do
      foo = double(cf_event_from: @today, cf_event_to: @today - 1.day)
      expect(foo).not_to receive(:errors)
      expect(CustomFieldPair).not_to receive(:find)
      @from.custom_validator(foo)
    end

    it "should call custom field validation on super class" do
      from = CustomFieldDatePair.new(name: 'cf_event_from', required: true)
      foo = double(cf_event_from: nil)
      err = double(:errors); allow(err).to receive(:add)
      expect(foo).to receive(:errors).and_return(err)
      from.custom_validator(foo)
    end
  end
end
