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

class CustomFieldDatePair < CustomFieldPair

  # Register this CustomField with the application
  #------------------------------------------------------------------------------
  register(:as => 'date_pair', :klass => 'CustomFieldDatePair', :type => 'date')

  # For rendering paired values
  # Handle case where both pairs are blank
  #------------------------------------------------------------------------------
  def render_value(object)
    return "" unless paired_with.present?
    from = render(object.send(name))
    to = render(object.send(paired_with.name))
    if from.present? and to.present?
      I18n.t('pair.from_to', :from => from, :to => to)
    elsif from.present? and !to.present?
      I18n.t('pair.from_only', :from => from)
    elsif !from.present? and to.present?
      I18n.t('pair.to_only', :to => to)
    else
      ""
    end
  end
  
  def render(value)
    value && value.strftime(I18n.t("date.formats.mmddyy"))
  end
  
  def custom_validator(obj)
    super
    # validate when we get to 2nd of the pair
    if pair_id.present?
      start = CustomFieldPair.find(pair_id)
      return if start.nil?
      from = obj.send(start.name)
      to = obj.send(name)
      obj.errors.add(name.to_sym, ::I18n.t('activerecord.errors.models.custom_field.endbeforestart', :field => start.label)) if from.present? and to.present? and (from > to)
    end
  end

end
