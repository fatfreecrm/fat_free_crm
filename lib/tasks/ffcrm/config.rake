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

namespace :ffcrm do
  namespace :config do

    desc "Setup database.yml"
    task :copy_database_yml do
      require 'fileutils'
      filename = "config/database.#{ENV['DB'] || 'postgres'}.yml"
      orig, dest = FatFreeCRM.root.join(filename), Rails.root.join('config/database.yml')
      unless File.exists?(dest)
        puts "Copying #{filename} to config/database.yml ..."
        FileUtils.cp orig, dest
      end
    end

    #
    # Syck is not maintained anymore and Rails now prefers Psych by default.
    # Soon, fat_free_crm should also make the move, which involves adjustments to yml files.
    # However, each FFCRM installation will have it's own syck style settings.yml files so we need to
    # provide help to migrate before switching it off. This task helps that process.
    #
    desc "Ensures all yaml files in the config folder are readable by Psych. If not, assumes file is in the Syck format and converts it for you [creates a new file]."
    task :syck_to_psych do
      error_count = 0
      total_files = 0
      Dir[File.join(Rails.root, 'config', '**', '*.yml')].each do |file|
        begin
          Psych.load_file(file)
        rescue Psych::SyntaxError => e
          puts e # prints error message with line number
          File.open("#{file}.new", 'w') {|f| f.puts Psych.dump(Syck.load_file(file)) }
          puts "Have written Psych compatible file to #{file}.new"
          error_count += 1
        end
        total_files += 1
      end
      puts "Scanned #{total_files} yml files. Found #{error_count} problems (see above)."
    end

  end
end
