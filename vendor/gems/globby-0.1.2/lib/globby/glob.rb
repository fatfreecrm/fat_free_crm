module Globby
  class Glob
    def initialize(pattern)
      pattern = pattern.dup
      @inverse = pattern.sub!(/\A!/, '')
      # remove meaningless wildcards
      pattern.sub!(/\A\/?(\*\*\/)+/, '')
      pattern.sub!(/(\/\*\*)+\/\*\z/, '/**')
      @pattern = pattern
    end

    def match(files)
      return [] unless files
      files.grep(to_regexp)
    end

    def inverse?
      @inverse
    end

    def directory?
      @pattern =~ /\/\z/
    end

    def exact_match?
      @pattern =~ /\A\// && @pattern !~ /[\*\?]/
    end

    # see https://www.kernel.org/doc/man-pages/online/pages/man7/glob.7.html
    GLOB_BRACKET_EXPR = /
      \[ # brackets
        !? # (maybe) negation
        \]? # (maybe) right bracket
        (?: # one or more:
          \[[^\/\]]+\] # named character class, collating symbol or equivalence class
          | [^\/\]] # non-right bracket character (could be part of a range)
        )+
      \]/x
    GLOB_ESCAPED_CHAR = /\\./
    GLOB_RECURSIVE_WILDCARD = /\/\*\*(?:\/|\z)/
    GLOB_WILDCARD = /[\?\*]/

    GLOB_TOKENIZER = /(
      #{GLOB_BRACKET_EXPR} |
      #{GLOB_ESCAPED_CHAR} |
      #{GLOB_RECURSIVE_WILDCARD}
    )/x

    def to_regexp
      parts = @pattern.split(GLOB_TOKENIZER) - [""]

      result = parts.first.sub!(/\A\//, '') ? '\A' : '(\A|/)'
      parts.each do |part|
        result << part_to_regexp(part)
      end
      if result[-1, 1] == '/'
        result << '\z'
      elsif result[-2, 2] == '.*'
        result.slice!(-2, 2)
      else
        result << '\/?\z'
      end
      Regexp.new result
    end

   private

    def part_to_regexp(part)
      case part
      when GLOB_BRACKET_EXPR
        # fix negation and escape right bracket
        part.sub(/\A\[!/, '[^').sub(/\A(\[\^?)\]/, '\1\]')
      when GLOB_ESCAPED_CHAR
        part
      when GLOB_RECURSIVE_WILDCARD
        part[-1, 1] == '/' ? "/(.+/)?" : "/.*"
      when GLOB_WILDCARD
        (part.split(/(#{GLOB_WILDCARD})/) - [""]).inject("") do |result, p|
          result << case p
            when '?'; '[^/]'
            when '*'; '[^/]' + (result.end_with?("/") ? '+' : '*')
            else Regexp.escape(p)
          end
        end
      else # literal path component (maybe with slashes)
        part
      end
    end
  end
end
