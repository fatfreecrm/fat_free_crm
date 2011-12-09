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

#~ require "source_annotation_extractor"

# Modified version of the SourceAnnotationExtractor from rails/lib/source_annotation_extractor.rb;
# searches executable code that calls a hook.
#------------------------------------------------------------------------------
class PluginSourceAnnotationExtractor < SourceAnnotationExtractor
  # Returns a hash that maps filenames under +dir+ (recursively) to arrays
  # with their annotations. Only files with annotations are included, and only
  # those with extension +.builder+, +.rb+, +.rxml+, +.rjs+, +.rhtml+, +.erb+,
  # and +.haml+ are taken into account.
  def find_in(dir)
    results = {}

    Dir.glob("#{dir}/*") do |item|
      next if File.basename(item)[0] == ?.

      if File.directory?(item)
        results.update(find_in(item))
      elsif item =~ /\.(builder|(r(?:b|xml|js)))$/
        results.update(extract_annotations_from(item, /^\s*[^#]\s*(#{tag})\((:[^\)]+)\)$/))
      elsif item =~ /\.haml$/
        results.update(extract_annotations_from(item, /^\s*[^\-][^#]\s*(#{tag})\((:[^\)]+)\)$/))
      elsif item =~ /\.(rhtml|erb)$/
        results.update(extract_annotations_from(item, /<%=[^#]\s*(#{tag})\((:[^\)]+)\)\s*%>/))
      end
    end

    results
  end
end

namespace :crm do
  desc "Enumerate all callback hooks and their parameters"
  task :hooks => :environment do
    PluginSourceAnnotationExtractor.enumerate "hook"
  end
end
