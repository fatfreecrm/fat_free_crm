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

    it "should not generate a new token if one exists" do
      FatFreeCRM::SecretTokenGenerator.stub(:token_exists?).and_return(true)
      FatFreeCRM::SecretTokenGenerator.should_not_receive(:new_token!)
      FatFreeCRM::SecretTokenGenerator.setup!
    end

    it "should generate a token if none exists" do
      FatFreeCRM::SecretTokenGenerator.stub(:token_exists?).and_return(false)
      FatFreeCRM::SecretTokenGenerator.should_receive(:new_token!)
      FatFreeCRM::SecretTokenGenerator.setup!
    end

    it "should generate a random token if not persisted" do
      FatFreeCRM::SecretTokenGenerator.stub(:token_exists?).and_return(false)
      FatFreeCRM::SecretTokenGenerator.stub(:new_token)
      FatFreeCRM::SecretTokenGenerator.should_receive(:generate_token).exactly(:twice)
      FatFreeCRM::SecretTokenGenerator.setup!
    end

  end

  describe "token_exists?" do

    it "should be true" do
      Setting.stub(:secret_token).and_return(token)
      FatFreeCRM::SecretTokenGenerator.send(:token_exists?).should eql(true)
    end

    it "should be false" do
      Setting.stub(:secret_token).and_return(nil)
      FatFreeCRM::SecretTokenGenerator.send(:token_exists?).should eql(false)
    end

  end

  describe "token" do

    it "should delegate to Setting" do
      Setting.should_receive(:secret_token).and_return(token)
      FatFreeCRM::SecretTokenGenerator.send(:token).should eql(token)
    end

  end

  describe "new_token!" do

    it "should generate and set a new token" do
      FatFreeCRM::SecretTokenGenerator.should_receive(:generate_token).and_return(token)
      Setting.should_receive(:secret_token=).with(token)
      FatFreeCRM::SecretTokenGenerator.send(:new_token!)
    end

  end

  describe "generate_token!" do

    it "should generate a random token" do
      SecureRandom.should_receive(:hex).with(64).and_return(token)
      FatFreeCRM::SecretTokenGenerator.send(:generate_token)
    end

  end

end
