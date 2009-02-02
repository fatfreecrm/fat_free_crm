module TasksHelper

  # Sidebar checkbox control for filtering tasks by due date -- used for
  # pending and assigned views only.
  #----------------------------------------------------------------------------
  def task_filter_checbox(view, filter, count)
    name = "filter_by_task_#{view}"
    checked = (session[name] ? session[name].split(",").include?(filter.to_s) : count > 0)
    check_box_tag("filters[]", filter, checked, :onclick => remote_function(:url => { :action => :filter, :view => view }, :with => %Q/"filters=" + $$("input[name='filters[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end

  # Returns true if the view has all filters unchecked resulting in empty task list.
  #----------------------------------------------------------------------------
  def all_filtered_out?(view)
    session["filter_by_task_#{view}"].blank?
  end

  #----------------------------------------------------------------------------
  def complete(pending)
    onclick = "this.disable();"
    onclick << %Q/$("#{dom_id(pending, :name)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => complete_task_path(pending), :method => :put)
  end

end
