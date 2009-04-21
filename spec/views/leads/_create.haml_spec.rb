require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_create.html.haml" do
  include LeadsHelper
  
  it "should render [create lead] form" do
    login_and_assign
    assigns[:lead] = Factory.build(:lead)

    template.should_receive(:render).with(hash_including(:partial => "leads/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "leads/status"))
    template.should_receive(:render).with(hash_including(:partial => "leads/contact"))
    template.should_receive(:render).with(hash_including(:partial => "leads/web"))
    template.should_receive(:render).with(hash_including(:partial => "leads/permissions"))

    render "/leads/_create.html.haml"
    response.should have_tag("form[class=new_lead]")
  end
end


