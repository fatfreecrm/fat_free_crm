# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class String
  alias_method :-, :delete

  def n2br
    strip.gsub("\n", "<br />")
  end

  def wrap(prefix, suffix = prefix)
    prefix + self + suffix
  end

  def digitize
    gsub(/[^\d]/, "")  # "$100,000".digitize # => 100000
  end

  def to_url
    match(/^https?:\/\//) ? self : "http://" << self
  end

  def true?
    self == "true"
  end

  def false?
    self == "false"
  end

  # Generates all permutations for first and last name, based on the order of parts
  # A query with 4 words will generate 6 permutations
  def name_permutations
    parts = split(" ")
    Array.new((parts.size - 1)) do |i|
      # ["A", "B", "C", "D"]  =>  [["A B C", "D"], ["A B", "C D"], ["A", "B C D"]]
      [parts[(0..i)].join(" "), parts[(i + 1)..-1].join(" ")]
    end.each_with_object([]) do |perm, arr|
      # Search both [first, last] and [last, first]
      # e.g. for every ["A B C", "D"], also include ["D", "A B C"]
      arr << perm
      arr << perm.reverse
      arr
    end
  end
end
