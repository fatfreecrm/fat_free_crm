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

require "csv"
class Array
  # NOTE: in ActiveRecord 2.x #visible_to was mixed into class
  # ActiveRecord::NamedScope::Scope but with AREL scope it must be Array.
  #
  # The following is used to filter out user activities based on activity
  # subject's permissions. For example:
  #
  # @current_user = User.find(1)
  # @activities = Activity.latest.execpt(:viewed).visible_to(@current_user)
  #
  # Note that we can't use named scope for the Activity since the join table
  # name is based on subject type, which is polymorphic.
  #----------------------------------------------------------------------------
  def visible_to(user)
    delete_if do |item|
      is_private = false
      if item.is_a?(Activity)
        subject = item.subject || item.subject_type.constantize.find_with_destroyed(item.subject_id)
        if subject.respond_to?(:access) # NOTE: Tasks don't have :access as of yet.
          is_private = subject.user_id != user.id && subject.assigned_to != user.id &&
            (subject.access == "Private" || (subject.access == "Shared" && !subject.permissions.map(&:user_id).include?(user.id)))
        end
      end
      is_private
    end
  end

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
