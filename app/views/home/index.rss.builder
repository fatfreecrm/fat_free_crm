# http://cyber.law.harvard.edu/rss/rss.html
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.generator  "Fat Free CRM v#{FatFreeCRM::Version}"
    xml.link       root_url
    xml.pubDate    Time.now.to_s(:rfc822)
    xml.title      t(:activities)

    @activities.each do |activity|
      xml.item do
        xml.author      activity.user.full_name
        # xml.guid        activity.id
        # xml.link        nil
        xml.pubDate     activity.created_at.to_s(:rfc822)
        xml.title       activity_title(activity)
      end
    end
  end
end
