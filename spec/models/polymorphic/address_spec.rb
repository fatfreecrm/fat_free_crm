# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: addresses
#
#  id               :integer         not null, primary key
#  street1          :string(255)
#  street2          :string(255)
#  city             :string(64)
#  state            :string(64)
#  zipcode          :string(16)
#  country          :string(64)
#  full_address     :string(255)
#  address_type     :string(16)
#  addressable_id   :integer
#  addressable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Address do
  it "should create a new instance given valid attributes" do
    Address.create!(street1: "street1", street2: "street2", city: "city", state: "state", zipcode: "zipcode", country: "country", full_address: "fa", address_type: "Lead", addressable: create(:lead))
  end
end
