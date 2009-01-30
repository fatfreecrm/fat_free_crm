module TasksHelper

  # Sidebar checkbox control for filtering tasks by due date -- used for
  # pending and assigned views only.
  #----------------------------------------------------------------------------
  def task_due_date_checbox(view, due_date, count)
    name = "filter_by_task_#{view}".intern
    checked = (session[name] ? session[name].split(",").include?(due_date.to_s) : count > 0)
    check_box_tag("due_date[]", due_date, checked, :onclick => remote_function(:url => { :action => :filter, :view => view }, :with => %Q/"due_date=" + $$("input[name='due_date[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
