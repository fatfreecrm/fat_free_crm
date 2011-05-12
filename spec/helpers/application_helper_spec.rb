require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  
  # Delete this example and add some real ones or delete this file.
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ApplicationHelper)
  end

  describe "link_to_emails" do
    it "should add Bcc: if dropbox address is set" do
      Setting.stub!(:email_dropbox).and_return({ :address => "drop@example.com" })
      helper.link_to_email("hello@example.com").should == '<a href="mailto:hello@example.com?bcc=drop@example.com" title="hello@example.com">hello@example.com</a>'
    end

    it "should not add Bcc: if dropbox address is not set" do
      Setting.stub!(:email_dropbox).and_return({ :address => nil })
      helper.link_to_email("hello@example.com").should == '<a href="mailto:hello@example.com" title="hello@example.com">hello@example.com</a>'
    end

    it "should truncate long emails" do
      Setting.stub!(:email_dropbox).and_return({ :address => nil })
      helper.link_to_email("hello@example.com", 5).should == '<a href="mailto:hello@example.com" title="hello@example.com">he...</a>'
    end

    it "should escape HTML entities" do
      Setting.stub!(:email_dropbox).and_return({ :address => 'dr&op@example.com' })
      helper.link_to_email("hell&o@example.com").should == '<a href="mailto:hell&amp;o@example.com?bcc=dr&amp;op@example.com" title="hell&amp;o@example.com">hell&amp;o@example.com</a>'
    end
  end

  it "link_to_discard" do
    lead = Factory(:lead)
    request.stub!(:request_uri).and_return("http://www.example.com/leads/#{lead.id}")

    link = helper.link_to_discard(lead)
    link.should =~ %r|leads/#{lead.id}/discard|
    link.should =~ %r|parameters:\{ attachment: 'Lead', attachment_id: #{lead.id} \}|
  end

  describe "shown_on_landing_page?" do
    it "should return true for Ajax request made from the asset landing page" do
      request.stub!(:xhr?).and_return(true)
      request.stub!(:referer).and_return("http://www.example.com/leads/123")
      helper.shown_on_landing_page?.should == true
    end

    it "should return true for regular request to display asset landing page" do
      request.stub!(:xhr?).and_return(false)
      request.stub!(:request_uri).and_return("http://www.example.com/leads/123")
      helper.shown_on_landing_page?.should == true
    end

    it "should return false for Ajax request made from page other than the asset landing page" do
      request.stub!(:xhr?).and_return(true)
      request.stub!(:referer).and_return("http://www.example.com/leads")
      helper.shown_on_landing_page?.should == false
    end

    it "should return false for regular request to display page other than asset landing page" do
      request.stub!(:xhr?).and_return(false)
      request.stub!(:request_uri).and_return("http://www.example.com/leads")
      helper.shown_on_landing_page?.should == false
    end
  end

  describe "path_to_delete_tag_for" do
    it "can generate a path for a lead" do
      lead = Factory(:lead)
      path = helper.path_to_delete_tag_for(lead)
      path.should == "/leads/#{lead.id}/delete_tag"
    end

    it "can generate a path for a contact" do
      contact = Factory(:contact)
      path = helper.path_to_delete_tag_for(contact)
      path.should == "/contacts/#{contact.id}/delete_tag"
    end

    it "can generate a path for an account" do
      account = Factory(:account)
      path = helper.path_to_delete_tag_for(account)
      path.should == "/accounts/#{account.id}/delete_tag"
    end
  end
  describe "assigned_to_select" do
    before :each do
      @user1 = Factory(:user, :first_name => "michael", :last_name => "smith")
      @user2 = Factory(:user, :first_name => "jack", :last_name => "wilson")
      @user3 = Factory(:user, :first_name => "anne", :last_name => "wilkinson")
      assigns[:users] = [@user1, @user2, @user3]
      assigns[:current_user] = @user2
      @opportunity = Factory(:opportunity, :assigned_to => nil)
    end
    it "should generate a select tag with the assigned user selected" do
      @opportunity.update_attributes(:assigned_to => @user1.id)
      (helper.assigned_to_select_for(@opportunity) =~ Regexp.new("<option value=\\\"#{@user1.id}\\\" selected=\\\"selected\\\">#{@user1.full_name}</option>")).should_not be_nil
    end
    it "should generate a select tag with the current_user selected by default" do
      (helper.assigned_to_select_for(@opportunity) =~ Regexp.new("<option value=\\\"#{@user2.id}\\\" selected=\\\"selected\\\">#{t(:myself)}</option>")).should_not be_nil
    end
    it "should include unassigned" do
      (helper.assigned_to_select_for(@opportunity) =~ Regexp.new("<option value=\\\"\\\">#{t(:unassigned)}</option>")).should_not be_nil
    end
  end
end
