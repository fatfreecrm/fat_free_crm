# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
