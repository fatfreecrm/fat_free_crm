module FilteringCheckboxHelper
  def filtering_checkbox(for_class, for_filter, value, default_checked = false, check_box_options = {})
    session_filters = session[:"filter_by_#{for_class.name.underscore}_#{for_filter}"]
    checked = session_filters ? session_filters.split(",").include?(value.to_s) : default_checked

    check_box_options = {
      :onclick => remote_function(:url => { :action => :filter },
                                  :with => %Q/"#{for_filter}=" + $$("input[name='#{for_filter}[]']").findAll(function (el) { return el.checked }).pluck("value")/)
    }.merge(check_box_options)

    check_box_tag("#{for_filter}[]", value, checked, check_box_options)
  end
end
