require 'spec_helper'
require 'controller_spec_controller'

describe "a controller spec running in isolation mode", :type => :controller do
  controller_name :controller_spec

  it "does not care if the specified template doesn't exist" do
    get 'some_action'
    response.should be_success
    response.should render_template("template/that/does/not/actually/exist")
  end
  
  it "does not care if the implied template doesn't exist" do
    get 'some_action_with_implied_template'
    response.should be_success
    response.should render_template("some_action_with_implied_template")
  end

  it "does not care if the template has errors" do
    get 'action_with_errors_in_template'
    response.should be_success
    response.should render_template("action_with_errors_in_template")
  end
  
  it "does not care if the template exists but the action doesn't" do
    get 'non_existent_action_with_existent_template'
    response.should be_success
  end
  
  it "fails if the neither the action nor the template exist" do
    expect {get 'non_existent_action'}.to raise_error(ActionController::UnknownAction)
  end
end

describe "a controller spec running in integration mode", :type => :controller do
  controller_name :controller_spec
  integrate_views

  it "renders a template" do
    get 'action_with_template'
    response.should be_success
    response.should have_tag('div', 'This is action_with_template.rhtml')
  end

  it "fails if the template doesn't exist" do
    error = defined?(ActionController::MissingTemplate) ? ActionController::MissingTemplate : ActionView::MissingTemplate    
    lambda { get 'some_action' }.should raise_error(error)
  end

  it "fails if the template has errors" do
    lambda { get 'action_with_errors_in_template' }.should raise_error(ActionView::TemplateError)
  end
  
  it "fails if the action doesn't exist" do
    expect {get 'non_existent_action'}.to raise_error(ActionController::UnknownAction)
  end
  
  describe "nested" do
    it "should render a template" do
      get 'action_with_template'
      response.should be_success
      response.should have_tag('div', 'This is action_with_template.rhtml')
    end
    
    describe "with integrate_views turned off" do
      integrate_views false
      
      it "should not care if the template doesn't exist" do
        get 'some_action'
        response.should be_success
        response.should render_template("template/that/does/not/actually/exist")
      end
    end
  end
end
