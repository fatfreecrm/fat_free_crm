# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe ApplicationController do
  describe "auto_complete_ids_to_exclude" do
    it "should return [] when related is nil" do
      expect(controller.send(:auto_complete_ids_to_exclude, nil)).to eq([])
    end

    it "should return [] when related is ''" do
      expect(controller.send(:auto_complete_ids_to_exclude, '')).to eq([])
    end

    it "should return campaign id 5 when related is '5' and controller is campaigns" do
      expect(controller.send(:auto_complete_ids_to_exclude, '5').sort).to eq([5])
    end

    it "should return [6, 9] when related is 'campaigns/7'" do
      allow(controller).to receive(:controller_name).and_return('opportunities')
      campaign = double(Campaign, opportunities: [double(id: 6), double(id: 9)])
      expect(Campaign).to receive(:find_by_id).with('7').and_return(campaign)
      expect(controller.send(:auto_complete_ids_to_exclude, 'campaigns/7').sort).to eq([6, 9])
    end

    it "should return [] when related object is not found" do
      expect(Campaign).to receive(:find_by_id).with('7').and_return(nil)
      expect(controller.send(:auto_complete_ids_to_exclude, 'campaigns/7')).to eq([])
    end

    it "should return [] when related object association is not found" do
      allow(controller).to receive(:controller_name).and_return('not_a_method_that_exists')
      campaign = double(Campaign)
      expect(Campaign).to receive(:find_by_id).with('7').and_return(campaign)
      expect(controller.send(:auto_complete_ids_to_exclude, 'campaigns/7')).to eq([])
    end
  end
end
