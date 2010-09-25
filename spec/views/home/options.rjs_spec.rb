require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/options.rjs" do
  include HomeHelper

  before(:each) do
    login_and_assign
  end

  it "should render [options.html.haml] template into :options div and show it" do
    params[:cancel] = nil

    assign(:asset, "all")
    assign(:user, "all_users")
    assign(:duration, "two_days")

    render

    rendered.should have_rjs("options") do |rjs|
      with_tag("input[type=hidden]") # @current_user

      user_menu = "onLoading:function(request){$('user').update('all users'); " +
                  "$('loading').show()}, parameters:'user=all_users'}); } } }"
      with_tag("script", /#{Regexp.escape(user_menu)}/)
    end
    rendered.should include('crm.flip_form("options")')
    rendered.should include('crm.set_title("title", "Recent Activity Options")')
  end

  it "should load :options partial with JavaScript code for menus" do
    params[:cancel] = nil
    render

    view.should render_template(:partial => "_options")
  end

  it "should hide options form on Cancel" do
    params[:cancel] = "true"
    render

    rendered.should_not have_rjs("options")
    rendered.should include('crm.flip_form("options")')
    rendered.should include('crm.set_title("title", "Recent Activity")')
  end

end
