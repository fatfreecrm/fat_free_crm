module Spec
  module Matchers
    # :call-seq:
    #   should match(regexp)
    #   should_not match(regexp)
    #
    # Given a Regexp, passes if actual =~ regexp
    #
    # == Examples
    #
    #   email.should match(/^([^\s]+)((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    def match(expected)
      Matcher.new :match, expected do |_expected_|
        match do |actual|
          actual =~ _expected_
        end
      end
    end
  end
end
