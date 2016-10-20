module Globby
  class Result < Array
    def initialize(files, dirs)
      @dirs = dirs
      super files.sort
    end

    def select(patterns)
      Globby::select(patterns, to_globject)
    end

    def reject(patterns)
      Globby::reject(patterns, to_globject)
    end

    def to_globject
      GlObject.new(self, @dirs)
    end
  end
end
