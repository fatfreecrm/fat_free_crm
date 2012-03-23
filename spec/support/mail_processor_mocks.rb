module MockIMAP
  def mock_imap
    @imap = mock
    @settings = @crawler.instance_variable_get("@settings")
    @settings[:address] = @mock_address
    Net::IMAP.stub!(:new).with(@settings[:server], @settings[:port], @settings[:ssl]).and_return(@imap)
  end

  def mock_connect
    mock_imap
    @imap.stub!(:login).and_return(true)
    @imap.stub!(:select).and_return(true)
  end

  def mock_disconnect
    @imap.stub!(:disconnected?).and_return(false)
    @imap.stub!(:logout).and_return(true)
    @imap.stub!(:disconnect).and_return(true)
  end

  def mock_message(body)
    @fetch_data = mock
    @fetch_data.stub!(:attr).and_return("RFC822" => body)
    @imap.stub!(:uid_search).and_return([ :uid ])
    @imap.stub!(:uid_fetch).and_return([ @fetch_data ])
    @imap.stub!(:uid_copy).and_return(true)
    @imap.stub!(:uid_store).and_return(true)
    body
  end
end
