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

class ActiveSupport::BufferedLogger

  BRIGHT = "\033[1;37;40m"
  NORMAL = "\033[0m"

  def p(*args)
    info "#{BRIGHT}\n\n" << args.join(" ") << "#{NORMAL}\n\n\n"
  end

  def i(*args)
    info "#{BRIGHT}\n\n" << args.map(&:inspect).join(" ") << "#{NORMAL}\n\n\n"
  end

end
