require 'open-uri'

module NetworkHelper
  def public_ip
    open("http://ping.eu") do |f| 
      /([0-9]{1,3}\.){3}[0-9]{1,3}/.match(f.read)[0]
    end
  end
end
