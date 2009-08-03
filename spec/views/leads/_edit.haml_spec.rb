require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/edit.html.erb" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead)
    assigns[:users] = [ @current_user ]
    assigns[:campaign] = @campaign = Factory(:campaign)
    assigns[:campaigns] = [ @campaign ]
  end

  it "should render [edit lead] form" do
    template.should_receive(:render).with(hash_including(:partial => "leads/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "leads/status"))
    template.should_receive(:render).with(hash_including(:partial => "leads/contact"))
    template.should_receive(:render).with(hash_including(:partial => "leads/web"))
    template.should_receive(:render).with(hash_including(:partial => "leads/permissions"))

    render "/leads/_edit.html.haml"
    response.should have_tag("form[class=edit_lead]") do
      with_tag "input[type=hidden][id=lead_user_id][value=#{@lead.user_id}]"
    end
  end

end


