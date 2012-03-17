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

class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::JavaScriptHelper

  def input
    add_autocomplete!
    field = @builder.text_field(
      attribute_name,
      input_html_options.merge(datetime_options(object.send(attribute_name)))
    )
    element_id = field[/id="([a-z0-9_]*)"/, 1]
    field << javascript_tag(%Q{crm.date_select_popup('#{element_id}', false, #{!!(input_type =~ /time/)});})
  end

  def label_target
    attribute_name
  end

  private

    def datetime_options(value = nil)
      return {} if value.nil?
      params = if input_type =~ /time/
        [value.localtime, {:format => :mmddyyyy_hhmm}]
      else
        [value.to_date, {:format => :mmddyyyy}]
      end
      { :value => I18n.localize(*params).html_safe }
    end

    def has_required?
      options[:required]
    end

    def add_autocomplete!
      input_html_options[:autocomplete] ||= 'off'
    end
end

