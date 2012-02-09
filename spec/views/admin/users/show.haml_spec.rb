require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/show" do
  before do
    assign(:user, @user = stub_model(User))
  end

  it "renders attributes" do
    render
  end
end

