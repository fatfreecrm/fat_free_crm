module WebkiosksHelper

# Generates a link to the webkiosks setup tracker page
  def setup_tracker_link(webkiosk)
    name = webkiosk.short_name.capitalize
    search_term = webkiosk.url.sub('http://','')
    html = "<a href=\"https://setup.livelinkprint.com/setup/search?setup[query]=#{search_term}\" target=\"_blank\">#{name}</a>"

    return raw(html)
  end

end
