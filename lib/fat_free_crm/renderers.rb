ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, :type => :csv,
    :disposition => "attachment; filename=#{filename}.csv"
end

ActionController::Renderers.add :xls do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_xls) ? obj.to_xls : obj.to_s
  send_data str, :type => :xls,
    :disposition => "attachment; filename=#{filename}.xls"
end

ActionController::Renderers.add :atom do |obj, options|
  render 'shared/index.atom.builder'
end

ActionController::Renderers.add :rss do |obj, options|
  render 'shared/index.rss.builder'
end
