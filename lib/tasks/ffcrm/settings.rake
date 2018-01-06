# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :settings do
    desc "Clear settings from database (reset to default)"
    task clear: :environment do
      Setting.delete_all
    end

    desc "Show current settings in the database"
    task show: :environment do
      Setting.select('name').order('name').pluck('name').each do |name|
        puts "\n#{name}:\n  #{Setting.send(name).inspect}"
      end
    end
  end
end
