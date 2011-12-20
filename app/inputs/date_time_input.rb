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

