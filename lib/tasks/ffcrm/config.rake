# frozen_string_literal: true

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
      orig = FatFreeCRM.root.join(filename)
      dest = Rails.root.join('config/database.yml')
      unless File.exist?(dest)
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
      require 'fileutils'
      require 'syck'
      require 'psych'
      Dir[File.join(Rails.root, 'config', '**', '*.yml')].each do |file_path|
        YAML::ENGINE.yamler = 'syck'
        puts "Converting #{file_path}"
        yml = YAML.load(File.read(file_path))
        FileUtils.cp file_path, "#{file_path}.bak"
        YAML::ENGINE.yamler = 'psych'
        File.open(file_path, 'w') { |file| file.write(YAML.dump(yml)) }
      end
    end
  end
end
