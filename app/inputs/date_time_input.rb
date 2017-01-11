# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  def input(wrapper_options)
    add_autocomplete!
    input_html_options.merge(input_options)
    input_html_options[:value] = value
    @builder.text_field(attribute_name, merge_wrapper_options(input_html_options, wrapper_options))
  end

  def label_target
    attribute_name
  end

  private

  def has_required?
    options[:required]
  end

  def add_autocomplete!
    input_html_options[:autocomplete] ||= 'off'
  end

  # Serialize into a value recognised by datepicker, also sorts out timezone conversion
  #------------------------------------------------------------------------------
  def value
    val = object.send(attribute_name)
    val.present? ? val.strftime('%Y-%m-%d %H:%M') : nil
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_date_time_input, self)
end
