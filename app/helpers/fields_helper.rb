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
      value = YAML.load(value) if String === value
      value.in_groups_of(2, false).map {|g| g.join(', ')}.join(tag(:br)) if Array === value
    else
      value.to_s
    end
  end
end

