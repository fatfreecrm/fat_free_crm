# http://cyber.law.harvard.edu/rss/rss.html
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title      t(:accounts)
    xml.desription "N/A"
    xml.link       accounts_url
    xml.pubDate    Time.now.to_s(:rfc822)
    xml.generator  "Fat Free CRM v#{FatFreeCRM::Version}"

    @accounts.each do |account|
      xml.item do
        xml.title       account.name
        xml.link        account_url(account)
        xml.description "N/A"
        xml.author      "N/A" # Creator: <author>email@example.com (Full Name)</author>
        xml.comments    "N/A"
        xml.guid        account_url(account)
        xml.pubDate     account.created_at.to_s(:rfc822)
      end
    end
  end
end
