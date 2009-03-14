require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  it "should assign @hello and call hook" do
    require_user
    controller.should_receive(:hook).at_least(:once)

    get :index
    assigns[:hello] = "world"
  end

  it "should toggle expand/collapse state of form section in the session (delete existing session key)" do
    session[:hello] = "world"

    xhr :get, :toggle, :id => "hello"
    session.data.keys.should_not include(:hello)
  end

  it "should toggle expand/collapse state of form section in the session (save new session key)" do
    session.data.delete(:hello)

    xhr :get, :toggle, :id => "hello"
    session[:hello] = "world"
  end

end
