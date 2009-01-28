module TasksHelper

  # Sidebar checkbox control for filtering tasks by due date.
  #----------------------------------------------------------------------------
  def task_due_date_checbox(due_date, count)
    checked = (session[:filter_by_task_due_date] ? session[:filter_by_task_due_date].split(",").include?(due_date.to_s) : count > 0)
    check_box_tag("due_date[]", due_date, checked, :onclick => remote_function(:url => { :action => :filter }, :with => %Q/"due_date=" + $$("input[name='due_date[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

end
