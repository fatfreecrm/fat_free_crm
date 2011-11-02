module FieldsHelper

  def display_value(object, field)
    value = object.try(field.name)

    case field.field_type
    when 'checkbox'
      value == 0 ? "no" : "yes"
    when 'date'
      value && value.strftime("%d/%m/%Y")
    when 'datetime'
      value && value.strftime("%d/%m/%Y %h:%m")
    when 'multi_select'
      # Comma separated, 2 per line.
      (Array === value ? value : [value]).in_groups_of(2).map { |g| g.join(', ') }.join(tag(:br))
    else
      value.to_s
    end
  end
end
