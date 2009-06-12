require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/options.rjs" do
  include HomeHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render [options.html.haml] template into :options div and show it" do
    params[:cancel] = nil
    render "home/options.js.rjs"
  
    response.should have_rjs("options") do |rjs|
      with_tag("input[type=hidden]") # @current_user
    end
    response.should include_text('crm.flip_form("options")')
    response.should include_text('crm.set_title("title", "Recent Activity Options")')
  end

  it "should load :options partial with JavaScript code for menus" do
    params[:cancel] = nil
    template.should_receive(:render).with(:partial => "options")
  
    render "home/options.js.rjs"
  end
  
  it "should hide options form on Cancel" do
    params[:cancel] = "true"
    render "home/options.js.rjs"

    response.should_not have_rjs("options")
    response.should include_text('crm.flip_form("options")')
    response.should include_text('crm.set_title("title", "Recent Activity")')
  end

end


