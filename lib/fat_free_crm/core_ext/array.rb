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

require "csv"
class Array
  # XLS export. Based on to_xls Rails plugin by Ary Djmal
  # https://github.com/arydjmal/to_xls
  #----------------------------------------------------------------------------
  def to_xls
    output =  '<?xml version="1.0" encoding="UTF-8"?><Workbook xmlns:x="urn:schemas-microsoft-com:office:excel"'
    output << ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40"'
    output << ' xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office">'
    output << '<Worksheet ss:Name="Sheet1"><Table>'

    if any?
      klass = first.class
      columns = klass.columns.map(&:name).reject { |column| column =~ /deleted_at|password|token/ }

      output << columns.map do |column|
        klass.human_attribute_name(column).wrap('<Cell><Data ss:Type="String">', '</Data></Cell>')
      end.join.wrap('<Row>', '</Row>')

      each do |item|
        output << columns.map do |column|
          value = if column =~ /^(user_id|assigned_to|completed_by)$/ && item.respond_to?(:"#{$1}_full_name")
            item.send(:"#{$1}_full_name")
          else
            item.send(column)
          end
          value = value.to_a.join(',') if [Set, Array].include?(value.class)
          value.to_s.wrap(%Q|<Cell><Data ss:Type="#{value.respond_to?(:abs) ? 'Number' : 'String'}">|, '</Data></Cell>')
        end.join.wrap('<Row>', '</Row>')
      end
    end

    output << '</Table></Worksheet></Workbook>'
  end

  # CSV export. Based on to_csv Rails plugin by Ary Djmal
  # https://github.com/arydjmal/to_csv
  #----------------------------------------------------------------------------
  def to_csv
    return '' if empty?

    klass = first.class
    columns = klass.columns.map(&:name).reject { |column| column =~ /password|token/ }

    CSV.generate do |csv|
      csv << columns.map { |column| klass.human_attribute_name(column) }
      each do |item|
        csv << columns.map { |column| item.send(column) }
      end
    end
  end
end
