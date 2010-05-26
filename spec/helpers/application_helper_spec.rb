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

end
