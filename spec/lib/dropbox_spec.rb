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

  #------------------------------------------------------------------------------ 
  describe "Connecting to the IMAP server" do
    it "should connect to the IMAP server and login as user" do
      mock_imap_connection
      @imap.should_receive(:login).once.with(@settings[:user], @settings[:password])
      @imap.should_not_receive(:select).with(@settings[:scan_folder])

      @crawler.connect
    end

    it "should connect to the IMAP server, login as user, and select folder" do
      mock_imap_connection
      @imap.should_receive(:login).once.with(@settings[:user], @settings[:password])
      @imap.should_receive(:select).once.with(@settings[:scan_folder])

      @crawler.connect(true)
    end

    it "should raise the error if connection fails" do
      Net::IMAP.should_receive(:new).and_raise(SocketError) # No mocks this time! :-)
      @crawler.connect
    end
  end

  #------------------------------------------------------------------------------ 
  describe "Disconnecting from the IMAP server" do
    it "should logout and diconnect" do
      mock_imap_connection
      @crawler.connect
      @imap.should_receive(:logout)#.once
      @imap.should_receive(:disconnect)#.once
      @crawler.disconnect
    end
  end

  #------------------------------------------------------------------------------ 
  describe "Discarding a message" do
    before(:each) do
      mock_imap_connection
      @crawler.instance_variable_set("@current_uid", @current_uid = mock)
      @crawler.connect
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

  # Archive message (valid) action based on settings from settings.yml
  #------------------------------------------------------------------------------     
  describe "Arciving a message" do
    before(:each) do
      mock_imap_connection
      @uid = mock
      @crawler.connect
    end

    it "should copy message to archive folder if it's set and flag the message as seen" do
      @settings[:move_to_folder] = "processed"
      @imap.should_receive(:uid_copy).once.with(@uid, @settings[:move_to_folder])
      @imap.should_receive(:uid_store).once.with(@uid, "+FLAGS", [:Seen])      
      @crawler.archive(@uid)
    end

    it "should not copy message to archive folder if it's not set and flag the message as seen" do
      @settings[:move_to_folder] = nil
      @imap.should_not_receive(:uid_copy)
      @imap.should_receive(:uid_store).once.with(@uid, "+FLAGS", [:Seen])
      @crawler.archive(@uid)
    end
  end

end
