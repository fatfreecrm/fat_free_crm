# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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
#
# Originally authored by Fernando Guillen under the name tmail-html-body-extractor
# and available on Google Code. See http://github.com/sant0sk1/tmail_body_extractors.
#
module TMail
  class Mail

    [ :html, :plain ].each do |type|
      define_method :"body_#{type}" do
        result = nil
        if multipart?
          parts.each do |part|
            if part.multipart?
              part.parts.each do |part2|
                result = part2.unquoted_body if part2.content_type =~ /#{type}/i
              end
            elsif !attachment?(part)
              result = part.unquoted_body if part.content_type =~ /#{type}/i
            end
          end
        else
          result = unquoted_body if content_type =~ /#{type}/i
        end
        result
      end
    end
    
  end
end