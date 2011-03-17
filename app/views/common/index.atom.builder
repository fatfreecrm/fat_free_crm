# http://www.atomenabled.org/developers/syndication/
items  = controller.controller_name
item   = items.singularize
assets = controller.instance_variable_get("@#{items}")

if item == 'task'
  assets = assets.values.flatten
  title  = t(:"#{@view}_tab") << ' ' << t(items.to_sym)
end

atom_feed do |feed|
  feed.title      title || t(items.to_sym)
  feed.updated    assets.any? ? assets.max { |a, b| a.updated_at <=> b.updated_at }.updated_at : Time.now
  feed.generator  "Fat Free CRM v#{FatFreeCRM::Version}"
  feed.author do |author|
    author.name  @current_user.full_name
    author.email @current_user.email
  end

  assets.each do |asset|
    feed.entry(asset) do |entry|
      entry.title   !asset.is_a?(User) ? asset.name : "#{asset.full_name} (#{asset.username})"
      entry.summary send(:"#{item}_summary", asset) if respond_to?(:"#{item}_summary")

      entry.author do |author|
        author.name !asset.is_a?(User) ? asset.user.full_name : asset.full_name
      end

      entry.contributor do |contributor|
        contributor.name asset.assigned_to_full_name
      end if asset.respond_to?(:assigned_to_full_name)
    end
  end
end
