require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index.html.haml" do
  include Admin::UsersHelper

  before(:each) do
    assigns[:users] = [
      stub_model(User),
      stub_model(User)
    ]
  end

  it "renders a list of users" do
    render
  end
end
