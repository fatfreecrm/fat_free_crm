# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :db do
  namespace :schema do

    desc "Upgrade your database schema from ids to timestamps"
    task :upgrade => :environment do
      timestamps = Dir.glob("db/migrate/*.rb").map{|f| File.basename(f)[/(\d+)/,1] }.sort
      timestamps[0..30].each_with_index do |timestamp, i|
        puts "== #{i+1} => #{timestamp}"
        ActiveRecord::Base.connection.
          execute("update schema_migrations set version=#{timestamp} where version='#{i+1}';")
      end
    end

  end
end
