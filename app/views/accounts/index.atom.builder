# http://www.atomenabled.org/developers/syndication/
atom_feed do |feed|
  feed.title t(:accounts)
  feed.updated @accounts.max { |a, b| a.updated_at <=> b.updated_at }.updated_at
  feed.generator  "Fat Free CRM v#{FatFreeCRM::Version}"
  feed.author do |author|
    author.name  @current_user.full_name
    author.email @current_user.email
  end

  @accounts.each do |account|
    feed.entry(account) do |entry|
      entry.title   account.name
      entry.summary "N/A"

      entry.author do |author| # Creator.
        author.name  "N/A"
        author.email "N/A"
      end

      entry.contributor do |contributor| # Assignee.
        contributor.name  "N/A"
        contributor.email "N/A"
      end
    end
  end
end
