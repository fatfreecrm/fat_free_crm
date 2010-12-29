# http://cyber.law.harvard.edu/rss/rss.html
items  = controller.controller_name
assets = instance_variable_get("@#{items}")

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.generator  "Fat Free CRM v#{FatFreeCRM::Version}"
    xml.link       send(:"#{items}_url")
    xml.pubDate    Time.now.to_s(:rfc822)
    xml.title      t(items.to_sym)

    assets.each do |asset|
      xml.item do
        url = send(:"#{items.singularize}_url", asset)
        xml.author      asset.user_id_full_name
        xml.description summary(asset)
        xml.guid        url
        xml.link        url
        xml.pubDate     asset.created_at.to_s(:rfc822)
        xml.title       asset.name
      end
    end
  end
end
