# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :settings do
  
    desc "Clear settings from database (reset to default)"
    task :clear => :environment do
      puts "== Clearing settings table..."

      # Truncate settings table
      ActiveRecord::Base.establish_connection(Rails.env)
      if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite"
        ActiveRecord::Base.connection.execute("DELETE FROM settings")
      else # mysql and postgres
        ActiveRecord::Base.connection.execute("TRUNCATE settings")
      end

      puts "===== Settings table has been cleared."
    end

    desc "Show current settings in the database"
    task :show => :environment do
      ActiveRecord::Base.establish_connection(Rails.env)
      names = ActiveRecord::Base.connection.select_values("SELECT name FROM settings ORDER BY name")
      names.each do |name|
        puts "\n#{name}:\n  #{Setting.send(name).inspect}"
      end
    end
    
  end
end
