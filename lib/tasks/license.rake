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

# Tasks for adding/removing license comment sections at beginning of files.
# Should be used in conjunction with the 'annotate' gem to annotate models
# with schema information.

namespace :license do
  FILES = {:ruby => [
              "app/helpers/**/*.rb",
              "app/models/**/*.rb",
              "app/controllers/**/*.rb",
              "lib/tasks/**/*.rake",
              "lib/fat_free_crm/**/*.rb",
              "lib/fat_free_crm.rb",
              "config/settings.default.yml",
              "config/settings.default.yml"
           ],
           :js => [
              "app/assets/javascripts/**/*.js",
              # Sass also uses javascript style comments
              "app/assets/stylesheets/**/*.sass"
           ],
           :css => [
              "app/assets/stylesheets/**/*.css"
           ]}
  
  LICENSE_RB = %Q{# Fat Free CRM
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

}
  LICENSES = {:ruby => LICENSE_RB,
              :js   => LICENSE_RB.gsub(/^#/, "//"),
              :css  => LICENSE_RB.gsub(/^# Fat Free/, "/*\n * Fat Free").
                                  gsub(/^#/, " \*").sub(/---\n/, "---\n */")}

  REGEXPS  = {:ruby => /^# Fat Free CRM\n# Copyright \(C\).*?\n(#.*\n)*#-{10}-*\n*/,
              :js   => /^\/\/ Fat Free CRM\n\/\/ Copyright \(C\).*?\n(\/\/.*\n)*\/\/-{10}-*\n*/,
              :css  => /^\/\*\n \* Fat Free CRM\n \* Copyright \(C\).*?\n( \*.*\n)* \*-{10}-*\n \*\/\n*/}
  
  def expand_globs(globs)
    globs.map{|f| Dir.glob(f) }.flatten.uniq
  end
  
  desc "Add license info to beginning of files"
  task :add do
    FILES.each do |lang, globs|
      expand_globs(globs).each do |file|
        puts "== Adding license to '#{file}'..."
        old_content = File.read(file)
        new_content = LICENSES[lang] + old_content.sub(REGEXPS[lang], '')
        
        File.open(file, "wb") { |f| f.puts new_content }
      end
    end
  end
  
  desc "Remove license from files"
  task :remove do
    FILES.each do |lang, globs|
      expand_globs(globs).each do |file|
        old_content = File.read(file)
        new_content = old_content.sub(REGEXPS[lang], '')
        if new_content != old_content
          File.open(file, "wb") { |f| f.puts new_content }
          puts "Removed license from '#{file}'."
        end
      end
    end
  end
end
