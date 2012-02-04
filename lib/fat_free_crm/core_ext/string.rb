# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class String

  alias :- :delete


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
    self.match(/^https?:\/\//) ? self : "http://" << self
  end


  def snakecase
    self.strip.downcase.gsub(/[\s\/]+/, "_")
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
    parts = self.split(" ")
    (parts.size - 1).times.map {|i|
      # ["A", "B", "C", "D"]  =>  [["A B C", "D"], ["A B", "C D"], ["A", "B C D"]]
      [parts[(0..i)].join(" "), parts[(i+1)..-1].join(" ")]
    }.inject([]) { |arr, perm|
      # Search both [first, last] and [last, first]
      # e.g. for every ["A B C", "D"], also include ["D", "A B C"]
      arr << perm
      arr << perm.reverse
      arr
    }
  end

end

