# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryBot.define do
  sequence :address do |_n|
    FFaker::Address.street_address + " " + FFaker::Address.secondary_address + "\n" + FFaker::Address.city + ", " + FFaker::AddressUS.state_abbr + " " + FFaker::AddressUS.zip_code
  end

  sequence :username do |n|
    FFaker::Internet.user_name + n.to_s # make sure it's unique by appending sequence number
  end

  sequence :website do |_n|
    "http://www." + FFaker::Internet.domain_name
  end

  sequence :title do |_n|
    ["", "Director", "Sales Manager", "Executive Assistant", "Marketing Manager", "Project Manager", "Product Manager", "Engineer"].sample
  end

  sequence :time do |n|
    Time.now - n.hours
  end

  sequence :date do |n|
    Date.today - n.days
  end
end
