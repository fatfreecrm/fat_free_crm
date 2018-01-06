# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module MockIMAP
  def mock_imap
    @imap = double
    @settings = @crawler.instance_variable_get("@settings")
    @settings[:address] = @mock_address
    allow(Net::IMAP).to receive(:new).with(@settings[:server], @settings[:port], @settings[:ssl]).and_return(@imap)
  end

  def mock_connect
    mock_imap
    allow(@imap).to receive(:login).and_return(true)
    allow(@imap).to receive(:select).and_return(true)
  end

  def mock_disconnect
    allow(@imap).to receive(:disconnected?).and_return(false)
    allow(@imap).to receive(:logout).and_return(true)
    allow(@imap).to receive(:disconnect).and_return(true)
  end

  def mock_message(body)
    @fetch_data = double
    allow(@fetch_data).to receive(:attr).and_return("RFC822" => body)
    allow(@imap).to receive(:uid_search).and_return([:uid])
    allow(@imap).to receive(:uid_fetch).and_return([@fetch_data])
    allow(@imap).to receive(:uid_copy).and_return(true)
    allow(@imap).to receive(:uid_store).and_return(true)
    body
  end
end
