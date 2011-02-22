module Spec # :nodoc:
  module Rails # :nodoc:
    module VERSION # :nodoc:
      unless defined? MAJOR
        MAJOR  = 1
        MINOR  = 3
        TINY   = 2
        PRE    = nil
      
        STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

        SUMMARY = "rspec-rails #{STRING}"
      end
    end
  end
end
