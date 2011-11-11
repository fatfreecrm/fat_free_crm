module FieldsHelper

  def display_value(object, field)
    value = object.send(field.name)

    case field.as
    when 'checkbox'
      value.to_s == '0' ? "no" : "yes"
    when 'date'
      value && value.strftime(I18n.t("date.formats.default"))
    when 'datetime'
      value && value.strftime(I18n.t("time.formats.short"))
    when 'check_boxes'
      # Comma separated, 2 per line.
      [value].flatten.in_groups_of(2).map { |g| g.compact.join(', ') }.join(tag(:br))
    else
      value.to_s
    end
  end
end
