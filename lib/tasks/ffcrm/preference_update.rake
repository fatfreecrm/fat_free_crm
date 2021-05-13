# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :preference_update do
    desc "Take all Marshal serialized database entries and convert them into JSON serialized"
    task run: :environment do
      preferences = Preference.all
      preferences.each do |preference|
        val = JSON.parse(Base64.decode64(preference.value), symbolize_name: true)
        preference.value = Base64.encode64(val.to_json)
      end
    end
  end
end
