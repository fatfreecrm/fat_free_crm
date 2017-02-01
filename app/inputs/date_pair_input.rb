# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class DatePairInput < SimpleForm::Inputs::Base
  # Output two date fields: start and end
  #------------------------------------------------------------------------------
  def input(wrapper_options)
    add_autocomplete!
    out = "<br />".html_safe

    field1, field2 = get_fields

    [field1, field2].compact.each do |field|
      out << '<div>'.html_safe
      label = field == field1 ? I18n.t('pair.start') : I18n.t('pair.end')
      [:required, :disabled].each { |k| input_html_options.delete(k) } # ensure these come from field not default options
      input_html_options.merge!(field.input_options)
      input_html_options[:value] = value(field)
      out << "<label#{' class="req"' if input_html_options[:required]}>#{label}</label>".html_safe
      text = @builder.text_field(field.name, merge_wrapper_options(input_html_options, wrapper_options))
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
    @field1 ||= Field.where(name: attribute_name).first
    @field2 ||= @field1.try(:paired_with)
    [@field1, @field2]
  end

  # Serialize into a value recognised by datepicker
  #------------------------------------------------------------------------------
  def value(field)
    val = object.send(field.name)
    val.present? ? val.strftime('%Y-%m-%d') : nil
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_date_pair_input, self)
end
