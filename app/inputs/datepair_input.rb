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

class DatepairInput < SimpleForm::Inputs::Base

  # Output two date fields: start and end
  #------------------------------------------------------------------------------
  def input
    add_autocomplete!
    out = "<br />".html_safe

    field1, field2 = get_fields
    
    [field1, field2].compact.each do |field|
      out << '<div>'.html_safe
      label = field==field1 ? I18n.t('pair.start') : I18n.t('pair.end')
      [:required, :disabled].each {|k| input_html_options.delete(k)} # ensure these come from field not default options
      input_html_options.merge!(field.input_options)
      input_html_options.merge!(:value => value(field))
      out << "<label#{' class="req"' if input_html_options[:required]}>#{label}</label>".html_safe
      text = @builder.text_field(field.name, input_html_options)
      out << text << '</div>'.html_safe
    end

    out
  end

  private

  # Returns true if either field is required?
  #------------------------------------------------------------------------------
  def required_field?
    get_fields.map(&:required).any?
  end

  # Turns autocomplete off unless told otherwise.
  #------------------------------------------------------------------------------
  def add_autocomplete!
    input_html_options[:autocomplete] ||= 'off'
  end
  
  # Datepicker latches onto the 'date' class.
  #------------------------------------------------------------------------------
  def input_html_classes
    super.push('date')
  end
  
  # Returns the pair as [field1, field2]
  #------------------------------------------------------------------------------
  def get_fields
    @field1 ||= CustomField.where(:name => attribute_name).first
    @field2 ||= @field1.try(:paired_with)
    [@field1, @field2]
  end
  
  # Serialize into a value recognised by datepicker
  #------------------------------------------------------------------------------
  def value(field)
    val = object.send(field.name)
    val.present? ? val.strftime('%Y-%m-%d') : nil
  end

end
