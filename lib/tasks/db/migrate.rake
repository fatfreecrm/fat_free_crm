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

Rake::Task.remove("db:migrate:status") # (Clears task so that it can be extended)

namespace :db do
  namespace :migrate do
  
    desc "Display status of migrations, including plugins"
    task :status => :environment do
      def find_migrations(path)
        Dir.glob(path).each do |file|
          # only files matching "20091231235959_some_name.rb" pattern
          if match_data = /(\d{14})_(.+)\.rb/.match(file)
            status = @db_list.delete(match_data[1]) ? 'up' : 'down'
            @file_list << [status, match_data[1], match_data[2]]
          end
        end
      end

      config = ActiveRecord::Base.configurations[Rails.env || 'development']
      @db_list = ActiveRecord::Base.connection.select_values("SELECT version FROM schema_migrations")
      @file_list = []

      # Find main migrations & plugin migrations
      find_migrations(File.join(Rails.root, 'db', 'migrate', '*'))
      find_migrations(File.join(Rails.root, 'vendor', 'plugins', '**', 'db', 'migrate', '*'))

      # output
      puts "\ndatabase: #{config['database']}\n\n"
      puts "#{"Status".center(8)}  #{"Migration ID".ljust(14)}  Migration Name"
      puts "-" * 50
      @file_list.each do |file|
        puts "#{file[0].center(8)}  #{file[1].ljust(14)}  #{file[2].humanize}"
      end
      @db_list.each do |version|
        puts "#{'up'.center(8)}  #{version.ljust(14)}  *** NO FILE ***"
      end
      puts
    end

    desc "Run plugin migrations"
    task :plugins => :environment do
      if Dir.glob("#{Rails.root}/vendor/plugins/*/db/migrate/*.rb").any?
        ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true

        # The following tweak becomes necessary when plugins start to depend
        # on each others migrations.
        # ------------------------------------------------------------------------------

        # Copy all plugin migrations to temp directory
        system("mkdir -p /tmp/plugin_migrations && rm -rf /tmp/plugin_migrations/* && \
                cp #{Rails.root}/vendor/plugins/*/db/migrate/*.rb /tmp/plugin_migrations")
        # Run all plugin migrations, ordered by timestamp
        ActiveRecord::Migrator.migrate("/tmp/plugin_migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
        # Remove temp migration directory
        system("rm -rf /tmp/plugin_migrations")

        Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end
    end

  end
end
