require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/new.html.erb" do
  include TasksHelper
  
  before(:each) do
    @current_user = Factory(:user)
    assigns[:task] = Task.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:due_at_hint] = %w(due_asap due_today)
    assigns[:category] = %w(meeting money)
  end
 
  it "create: should render [new.html.haml] template into :create_task div" do
    params[:cancel] = nil
    render "tasks/new.js.rjs"
    
    response.should have_rjs("create_task") do |rjs|
      with_tag("form[class=new_task]")
    end
  end

end


