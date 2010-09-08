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
