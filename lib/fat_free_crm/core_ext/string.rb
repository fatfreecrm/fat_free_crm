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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
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

end
