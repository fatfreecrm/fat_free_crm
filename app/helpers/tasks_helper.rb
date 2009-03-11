module TasksHelper

  # Sidebar checkbox control for filtering tasks by due date -- used for
  # pending and assigned views only.
  #----------------------------------------------------------------------------
  def task_filter_checbox(view, filter, count)
    name = "filter_by_task_#{view}"
    checked = (session[name] ? session[name].split(",").include?(filter.to_s) : count > 0)
    check_box_tag("filters[]", filter, checked, :onclick => remote_function(:url => { :action => :filter, :view => view }, :with => "{filter: this.value, checked:this.checked}" ))
  end

  #----------------------------------------------------------------------------
  def filtered_out?(view, filter = nil)
    name = "filter_by_task_#{view}"
    if filter
      filters = (session[name].nil? ? [] : session[name].split(","))
      !filters.include?(filter.to_s)
    else
      session[name].blank?
    end
  end

  #----------------------------------------------------------------------------
  def link_to_task_edit(task, bucket)
    link_to_remote("Edit",
      :url    => edit_task_path(task),
      :method => :get,
      :with   => "{ bucket: '#{bucket}', view: '#{@view}', previous: crm.find_form('edit_task') }"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_task_delete(task, bucket)
    link_to_remote("Delete!",
      :url    => task_path(task),
      :method => :delete,
      :with   => "{ bucket: '#{bucket}', view: '#{@view}' }",
      :before => visual_effect(:highlight, dom_id(task), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_task_complete(pending, bucket)
    onclick = "this.disable();"
    onclick << %Q/$("#{dom_id(pending, :name)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => complete_task_path(pending), :method => :put, :with => "{ bucket: '#{bucket}' }")
  end

end
