# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'spec_helper'
require 'fat_free_crm/secret_token_generator'

describe FatFreeCRM::SecretTokenGenerator do

  let(:token) { 'e5a4b315c062dec4ecb40dabcde84fd6c067cb016a813702d2f4299ad16255c88ed1020bd47fb527e8e5f7052b04be1fbb8e63c043b8fb36f88d3c7d79a68681' }

  describe "setup!" do

    it "should not generate a token if one already exists" do
      FatFreeCRM::SecretTokenGenerator.stub(:token).and_return(nil)
      expect(FatFreeCRM::SecretTokenGenerator).to receive(:generate_and_persist_token!)
      FatFreeCRM::Application.config.stub(:secret_token).and_return(token)
      FatFreeCRM::SecretTokenGenerator.setup!
    end

    it "should generate a token if none exists already" do
      FatFreeCRM::SecretTokenGenerator.stub(:token).and_return(token)
      expect(FatFreeCRM::SecretTokenGenerator).not_to receive(:generate_and_persist_token!)
      FatFreeCRM::SecretTokenGenerator.setup!
    end

    it "should raise an error if the token is still blank (should never happen)" do
      FatFreeCRM::SecretTokenGenerator.stub(:token).and_return(nil)
      lambda { FatFreeCRM::SecretTokenGenerator.setup! }.should raise_error(RuntimeError)
    end

  end

  describe "token" do

    it "should delegate to Setting" do
      expect(Setting).to receive(:secret_token).and_return(token)
      expect(FatFreeCRM::SecretTokenGenerator.send(:token)).to eql(token)
    end

  end

  describe "generate_and_persist_token!" do

    it "should generate a random token" do
      expect(SecureRandom).to receive(:hex).with(64).and_return(token)
      expect(Setting).to receive(:secret_token=).with(token)
      FatFreeCRM::SecretTokenGenerator.send(:generate_and_persist_token!)
    end

  end

end
