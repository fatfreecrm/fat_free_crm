# Table name: webkiosks
#
# id                  :integer         Primary key
# url                 :string          jessops.photokio.sk
# account_id          :references      account its linked to, key
# live                :boolean         live or not
# platform            :string          rails 2 or rails 3
# notes               :text            Any extra info

class Webkiosk < ActiveRecord::Base
  belongs_to :account
  validate :account_id
  validates :url, uniqueness: true, format: { with: /http:\/\/.*/}

  def short_name
    name = self.url.sub('http://','')
    name.split('.').first
  end

end
