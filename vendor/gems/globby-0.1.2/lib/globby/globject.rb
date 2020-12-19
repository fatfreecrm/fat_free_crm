module Globby
  class GlObject
    attr_reader :files, :dirs

    def initialize(files = Set.new, dirs = Set.new)
      @files = files
      @dirs = dirs
    end

    def self.all
      files, dirs = Dir.glob('**/*', File::FNM_DOTMATCH).
        reject { |f| f =~ /(\A|\/)\.\.?\z/ }.
        partition { |f| File.file?(f) || File.symlink?(f) }
      dirs.map!{ |d| d + "/" }
      new(files, dirs)
    end
  end
end
