module Spec # :nodoc:
  module Rails # :nodoc:
    module VERSION # :nodoc:
      unless defined? MAJOR
        MAJOR  = 1
        MINOR  = 2
        TINY   = 7

        STRING = [MAJOR, MINOR, TINY].compact.join('.')

        SUMMARY = "rspec-rails #{STRING}"
      end
    end
  end
end
