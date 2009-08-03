require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_edit.html.haml" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
    assigns[:account] = @account = Factory(:account)
    assigns[:users] = [ @current_user ]
  end

  it "should render [edit account] form" do
    template.should_receive(:render).with(hash_including(:partial => "accounts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "accounts/contact_info"))
    template.should_receive(:render).with(hash_including(:partial => "accounts/permissions"))

    render "/accounts/_edit.html.haml"
    response.should have_tag("form[class=edit_account]") do
      with_tag "input[type=hidden][id=account_user_id][value=#{@account.user_id}]"
    end
  end
end


