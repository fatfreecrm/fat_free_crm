module KiosksHelper

# Generates a link to the kiosks managelabs page
  def manage_labs_link(kiosk)
    name = kiosk.short_name
    html = "<a href=\"http://ubuntu.livelinkprint.com/manage_labs/search?q=#{name}\" target=\"_blank\"> #{kiosk.name}</a>"

    return raw(html)
  end
end
