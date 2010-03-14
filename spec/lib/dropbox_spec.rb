require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "IMAP Dropbox" do
  before(:each) do
    @crawler = FatFreeCRM::Dropbox.new
  end

  def mock_imap_connection
    @imap = mock
    @settings = @crawler.instance_variable_get("@settings")
    Net::IMAP.stub!(:new).with(@settings[:server], @settings[:port], @settings[:ssl]).and_return(@imap)
  end

  def mock_connect
    mock_imap_connection
    @imap.stub!(:login)
    @imap.stub!(:select)
    @crawler.connect
  end

  #------------------------------------------------------------------------------ 
  describe "Connecting to the IMAP server" do
    it "should connect to the IMAP server and login as user, and select folder" do
      mock_imap_connection
      @imap.should_receive(:login).once.with(@settings[:user], @settings[:password])
      @imap.should_receive(:select).once.with(@settings[:scan_folder])
      @crawler.connect
    end

    it "should connect to the IMAP server, login as user, but not select folder when requested so" do
      mock_imap_connection
      @imap.should_receive(:login).once.with(@settings[:user], @settings[:password])
      @imap.should_not_receive(:select).with(@settings[:scan_folder])
      @crawler.connect(false)
    end

    it "should raise the error if connection fails" do
      Net::IMAP.should_receive(:new).and_raise(SocketError) # No mocks this time! :-)
      lambda { @crawler.connect }.should raise_error SystemExit
    end
  end

  #------------------------------------------------------------------------------ 
  describe "Disconnecting from the IMAP server" do
    it "should logout and diconnect" do
      mock_connect
      @imap.should_receive(:logout).once
      @imap.should_receive(:disconnect).once
      @crawler.disconnect
    end
  end

  #------------------------------------------------------------------------------ 
  describe "Discarding a message" do
    before(:each) do
      mock_connect
      @crawler.instance_variable_set("@current_uid", @current_uid = mock)
    end

    it "should copy message to invalid folder if it's set and flag the message as deleted" do
      @settings[:move_invalid_to_folder] = "invalid"
      @imap.should_receive(:uid_copy).once.with(@current_uid, @settings[:move_invalid_to_folder])
      @imap.should_receive(:uid_store).once.with(@current_uid, "+FLAGS", [:Deleted])      
      @crawler.discard
    end

    it "should not copy message to invalid folder if it's not set and flag the message as deleted" do
      @settings[:move_invalid_to_folder] = nil
      @imap.should_not_receive(:uid_copy)
      @imap.should_receive(:uid_store).once.with(@current_uid, "+FLAGS", [:Deleted])      
      @crawler.discard
    end
  end

  #------------------------------------------------------------------------------     
  describe "Arciving a message" do
    before(:each) do
      mock_connect
      @crawler.instance_variable_set("@current_uid", @current_uid = mock)
    end

    it "should copy message to archive folder if it's set and flag the message as seen" do
      @settings[:move_to_folder] = "processed"
      @imap.should_receive(:uid_copy).once.with(@current_uid, @settings[:move_to_folder])
      @imap.should_receive(:uid_store).once.with(@current_uid, "+FLAGS", [:Seen])
      @crawler.archive
    end

    it "should not copy message to archive folder if it's not set and flag the message as seen" do
      @settings[:move_to_folder] = nil
      @imap.should_not_receive(:uid_copy)
      @imap.should_receive(:uid_store).once.with(@current_uid, "+FLAGS", [:Seen])
      @crawler.archive
    end
  end

  #------------------------------------------------------------------------------
  describe "Validating a message" do
    before(:each) do
      @email = mock
      @from = [ "Aaron@Example.Com", "Ben@Example.com" ]
      @email.stub!(:sent_from).and_return(@from)
    end

    it "should discard email if its contents type is not text/plain" do
      @email.stub!(:content_type).and_return("text/html")
      @crawler.validate_and_find_user(@email).should == nil
    end

    describe "text/plain emails" do
      before(:each) do
        @email.stub!(:content_type).and_return("text/plain")
      end

      it "should accept text/plain email if there is non-suspended user that matches From: field" do
        @user = Factory(:user, :email => @from.first, :suspended_at => nil)
        @crawler.validate_and_find_user(@email).should == @user
      end

      it "should discard text/plain email if user doesn't match From: field" do
        Factory(:user, :email => "nobody@example.com")
        @crawler.validate_and_find_user(@email).should == nil
      end

      it "should discard text/plain email if user matches From: field but is suspended" do
        Factory(:user, :email => @from.first, :suspended_at => Time.now)
        @crawler.validate_and_find_user(@email).should == nil
      end
    end
  end

end
