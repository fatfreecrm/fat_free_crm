# http://www.atomenabled.org/developers/syndication/
items = controller.controller_name
assets = controller.instance_variable_get("@#{items}")

atom_feed do |feed|
  feed.title t(items.to_sym)
  feed.updated assets.max { |a, b| a.updated_at <=> b.updated_at }.updated_at
  feed.generator  "Fat Free CRM v#{FatFreeCRM::Version}"
  feed.author do |author|
    author.name  @current_user.full_name
    author.email @current_user.email
  end

  assets.each do |asset|
    feed.entry(asset) do |entry|
      entry.title   asset.name
      entry.summary summary(asset)

      entry.author do |author|
        author.name asset.user_id_full_name
      end

      entry.contributor do |contributor|
        contributor.name asset.assigned_to_full_name
      end
    end
  end
end
