require 'set'
require 'globby/glob'
require 'globby/globject'
require 'globby/result'

module Globby
  class << self
    def select(patterns, source = GlObject.all)
      result = GlObject.new
      evaluate_patterns(patterns, source, result)

      if result.dirs && result.dirs.size > 0
        # now go merge/subtract files under directories
        dir_patterns = result.dirs.map{ |dir| "/#{dir}**" }
        evaluate_patterns(dir_patterns, GlObject.new(source.files), result)
      end

      Result.new result.files, source.dirs
    end

    def reject(patterns, source = GlObject.all)
      Result.new(source.files - select(patterns, source), source.dirs)
    end

   private

    def evaluate_patterns(patterns, source, result)
      patterns.each do |pattern|
        next unless pattern =~ /\A[^#]/
        evaluate_pattern pattern, source, result
      end
    end

    def evaluate_pattern(pattern, source, result)
      glob = Globby::Glob.new(pattern)
      method, candidates = glob.inverse? ?
        [:subtract, result] :
        [:merge, source]

      dir_matches = glob.match(candidates.dirs)
      file_matches = []
      file_matches = glob.match(candidates.files) unless glob.directory? || glob.exact_match? && !dir_matches.empty?
      result.dirs.send method, dir_matches unless dir_matches.empty?
      result.files.send method, file_matches unless file_matches.empty?
    end
  end
end
