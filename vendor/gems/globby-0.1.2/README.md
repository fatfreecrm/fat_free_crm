# globby

[<img src="https://travis-ci.org/jenseng/globby.svg" />](http://travis-ci.org/jenseng/globby)

globby is a [`.gitignore`](http://www.kernel.org/pub/software/scm/git/docs/gitignore.html)-style
file globber for ruby.

## Installation

Put `gem 'globby'` in your Gemfile.

## Usage

    # all files matched by the rules
    Globby.select(rules)

    # all other files
    Globby.reject(rules)

    # ooh chaining!
    Globby.select(rules).reject(other_rules)

### An example:

     > rules = File.read('.gitignore').split(/\n/)
    -> ["Gemfile.lock", "doc", "*.gem"]

     > pp Globby.select(rules)
    ["Gemfile.lock",
     "doc/Foreigner.html",
     "doc/Foreigner/Adapter.html",
     "doc/Gemfile.html",
     "doc/Immigrant.html",
     ...
     "immigrant-0.1.3.gem",
     "immigrant-0.1.4.gem"]
    => nil

## Why on earth would I ever use this?

* You're curious what is getting `.gitignore`'d and/or you want to do something
  with those files.
* You're writing a library/tool that will have its own list of ignored/tracked
  files. My use case is for an I18n library that extracts strings from ruby
  files... I need to provide users a nice configurable way to blacklist given
  files/directories/patterns.

## Compatibility Notes

globby is compatible with `.gitignore` rules; it respects negated patterns, and
ignores comments or empty patterns. That said, it supports some things that may
or may not work in your version of git. These platform-dependent `.gitignore`
behaviors are platform independent in globby and can always be used:

 * Recursive wildcards à la ant/zsh/ruby. `**` matches directories recursively.
 * [glob(7)](https://www.kernel.org/doc/man-pages/online/pages/man7/glob.7.html)-style
   bracket expressions, i.e. character classes, ranges, complementation, named
   character classes, collating symbols and equivalence class expressions. Note
   that the syntax for some of these is slightly different than what you would
   find in regular expressions. Refer to [the documentation](https://www.kernel.org/doc/man-pages/online/pages/man7/glob.7.html)
   for more info.

## License

Copyright (c) 2013-2016 Jon Jensen, released under the MIT license
