# frozen_string_literal: true

# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'spec_helper'
require 'fat_free_crm/secret_token_generator'

describe FatFreeCrm::SecretTokenGenerator do
  let(:token) { 'e5a4b315c062dec4ecb40dabcde84fd6c067cb016a813702d2f4299ad16255c88ed1020bd47fb527e8e5f7052b04be1fbb8e63c043b8fb36f88d3c7d79a68681' }

  describe "setup!" do
    it "should not generate a new token if one exists" do
      allow(FatFreeCrm::SecretTokenGenerator).to receive(:token_exists?).and_return(true)
      expect(FatFreeCrm::SecretTokenGenerator).not_to receive(:new_token!)
      FatFreeCrm::SecretTokenGenerator.setup!
    end

    it "should generate a token if none exists" do
      allow(FatFreeCrm::SecretTokenGenerator).to receive(:token_exists?).and_return(false)
      expect(FatFreeCrm::SecretTokenGenerator).to receive(:new_token!)
      FatFreeCrm::SecretTokenGenerator.setup!
    end

    it "should generate a random token if not persisted" do
      allow(FatFreeCrm::SecretTokenGenerator).to receive(:token_exists?).and_return(false)
      allow(FatFreeCrm::SecretTokenGenerator).to receive(:new_token)
      expect(FatFreeCrm::SecretTokenGenerator).to receive(:generate_token).exactly(:twice)
      FatFreeCrm::SecretTokenGenerator.setup!
    end
  end

  describe "token_exists?" do
    it "should be true" do
      allow(Setting).to receive(:secret_token).and_return(token)
      expect(FatFreeCrm::SecretTokenGenerator.send(:token_exists?)).to eql(true)
    end

    it "should be false" do
      allow(Setting).to receive(:secret_token).and_return(nil)
      expect(FatFreeCrm::SecretTokenGenerator.send(:token_exists?)).to eql(false)
    end
  end

  describe "token" do
    it "should delegate to Setting" do
      expect(Setting).to receive(:secret_token).and_return(token)
      expect(FatFreeCrm::SecretTokenGenerator.send(:token)).to eql(token)
    end
  end

  describe "new_token!" do
    it "should generate and set a new token" do
      expect(FatFreeCrm::SecretTokenGenerator).to receive(:generate_token).and_return(token)
      expect(Setting).to receive(:secret_token=).with(token)
      FatFreeCrm::SecretTokenGenerator.send(:new_token!)
    end
  end

  describe "generate_token!" do
    it "should generate a random token" do
      expect(SecureRandom).to receive(:hex).with(64).and_return(token)
      FatFreeCrm::SecretTokenGenerator.send(:generate_token)
    end
  end
end
