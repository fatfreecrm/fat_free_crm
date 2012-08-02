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

class DatetimepairInput < SimpleForm::Inputs::DateTimeInput
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::JavaScriptHelper

  # Output two datetime fields: start and end
  #------------------------------------------------------------------------------
  def input
    add_autocomplete!
    out = "<br />".html_safe

    field1 = CustomField.where(:name => attribute_name).first
    field2 = field1.try(:paired_with)
    
    [field1, field2].compact.each do |field|
      out << ((field == field1) ? I18n.t('pair.start') : I18n.t('pair.end'))
      input_options = input_html_options.merge(datetimepair_options(object, field))
      text = @builder.text_field(field.name, input_options)
      element_id = text[/id="([a-z0-9_]*)"/, 1]
      text << javascript_tag(%Q{crm.date_select_popup('#{element_id}', false, #{!!(input_type =~ /time/)});})
      out << text
    end
    
    out
  end

  def label_target
    attribute_name
  end

  private

  def datetimepair_options(obj, field)
    value = obj.send(field.name)
    input_options = 
      if value.present?
        params = if input_type =~ /time/
          [value.localtime, {:format => :mmddyyyy_hhmm}]
        else
          [value.to_date, {:format => :mmddyyyy}]
        end
        { :value => I18n.localize(*params).html_safe }
      else
        {}
      end
    opts = field.input_options
    input_options.merge!(:placeholder => opts[:placeholder])
    input_options.merge!(:maxlength => opts[:input_html][:maxlength])
  end

  def has_required?
    options[:required]
  end

  def add_autocomplete!
    input_html_options[:autocomplete] ||= 'off'
  end

end
