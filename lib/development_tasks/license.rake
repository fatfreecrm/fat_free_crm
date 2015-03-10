# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# Tasks for adding/removing license comment sections at beginning of files.
# Should be used in conjunction with the 'annotate' gem to annotate models
# with schema information.

namespace :license do
  FILES = { ruby: [
    "app/**/*.rb",
    "app/**/*.coffee",
    "lib/**/*.rake",
    "lib/fat_free_crm/**/*.rb",
    "lib/fat_free_crm.rb",
    "spec/**/*.rb",
    "spec/spec_helper.rb",
    "config/**/*.rb",
    "config/settings.default.yml"
  ],
            js: [
              "app/assets/javascripts/**/*.js",
              "app/assets/stylesheets/**/*.sass", # Sass also uses javascript style comments
              "app/assets/stylesheets/**/*.scss"
            ],
            css: [
              "app/assets/stylesheets/**/*.css"
            ] }

  LICENSE_RB = %{# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
}
  LICENSES = { ruby: LICENSE_RB,
               js: LICENSE_RB.gsub(/^#/, "//"),
               css: LICENSE_RB.gsub(/^# Fat Free/, "/*\n * Fat Free")
                    .gsub(/^#/, " \*").sub(/---\n/, "---\n */") }

  REGEXPS  = { ruby: /^# Fat Free CRM\n# Copyright \(C\).*?\n(#.*\n)*#-{10}-*\n*/,
               js: /^\/\/ Fat Free CRM\n\/\/ Copyright \(C\).*?\n(\/\/.*\n)*\/\/-{10}-*\n*/,
               css: /^\/\*\n \* Fat Free CRM\n \* Copyright \(C\).*?\n( \*.*\n)* \*-{10}-*\n \*\/\n*/ }

  def expand_globs(globs)
    globs.map { |f| Dir.glob(f) }.flatten.uniq
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
