# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
FactoryGirl.define do
  sequence :address do |n|
    Faker::Address.street_address + " " + Faker::Address.secondary_address + "\n"
    Faker::Address.city + ", " + Faker::Address.us_state_abbr + " " + Faker::Address.zip_code
  end

  sequence :username do |n|
    Faker::Internet.user_name + n.to_s  # make sure it's unique by appending sequence number
  end

  sequence :website do |n|
    "http://www." + Faker::Internet.domain_name
  end

  sequence :title do |n|
    [ "", "Director", "Sales Manager",  "Executive Assistant", "Marketing Manager", "Project Manager", "Product Manager", "Engineer" ].sample
  end

  sequence :time do |n|
    Time.now - n.hours
  end

  sequence :date do |n|
    Date.today - n.days
  end

end
