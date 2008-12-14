# == Schema Information
# Schema version: 10
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  username          :string(32)      default(""), not null
#  email             :string(64)      default(""), not null
#  first_name        :string(32)
#  last_name         :string(32)
#  uuid              :string(36)
#  password_hash     :string(255)     default(""), not null
#  password_salt     :string(255)     default(""), not null
#  remember_token    :string(255)     default(""), not null
#  perishable_token  :string(255)     default(""), not null
#  openid_identifier :string(255)
#  last_request_at   :datetime
#  last_login_at     :datetime
#  current_login_at  :datetime
#  last_login_ip     :string(255)
#  current_login_ip  :string(255)
#  login_count       :integer(4)      default(0), not null
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :username => "username",
      :password => "password",
      :password_confirmation => "password",
      :email => "user@example.com"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end
end
