require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include PrototypeHelper

describe ApplicationHelper do

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
    controller.request.stub!(:fullpath).and_return("http://www.example.com/leads/#{lead.id}")

    link = helper.link_to_discard(lead)
    link.should =~ %r|leads/#{lead.id}/discard|
    link.should =~ %r|parameters:'attachment=Lead&amp;attachment_id=#{lead.id}'\}|
  end

  describe "shown_on_landing_page?" do
    it "should return true for Ajax request made from the asset landing page" do
      controller.request.stub!(:xhr?).and_return(true)
      controller.request.stub!(:referer).and_return("http://www.example.com/leads/123")
      helper.shown_on_landing_page?.should == true
    end

    it "should return true for regular request to display asset landing page" do
      controller.request.stub!(:xhr?).and_return(false)
      controller.request.stub!(:fullpath).and_return("http://www.example.com/leads/123")
      helper.shown_on_landing_page?.should == true
    end

    it "should return false for Ajax request made from page other than the asset landing page" do
      controller.request.stub!(:xhr?).and_return(true)
      controller.request.stub!(:referer).and_return("http://www.example.com/leads")
      helper.shown_on_landing_page?.should == false
    end

    it "should return false for regular request to display page other than asset landing page" do
      controller.request.stub!(:xhr?).and_return(false)
      controller.request.stub!(:fullpath).and_return("http://www.example.com/leads")
      helper.shown_on_landing_page?.should == false
    end
  end
end
