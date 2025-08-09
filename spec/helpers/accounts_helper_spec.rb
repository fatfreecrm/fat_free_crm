# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsHelper do
  let(:assignee) { create(:user) }
  # Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    expect(included_modules).to include(AccountsHelper)
  end
  describe '#display_pipeline' do
    context 'when the pipeline is zero' do
      it 'returns "N/A"' do
        expect(display_value(0)).to eq('N/A')
      end
    end
    context 'when the pipeline is has 300' do
      it 'returns "$300"' do
        expect(display_value(300)).to eq('$300')
      end
    end
  end
  describe '#display_won' do
    context 'when the won is zero' do
      it 'returns "N/A"' do
        expect(display_value(0)).to eq('N/A')
      end
    end
    context 'when the won is has 300' do
      it 'returns "$300"' do
        expect(display_value(300)).to eq('$300')
      end
    end
  end
  describe '#display_lost' do
    context 'when the lost is zero' do
      it 'returns "N/A"' do
        expect(display_value(0)).to eq('N/A')
      end
    end
    context 'when the lost is has 300' do
      it 'returns "$300"' do
        expect(display_value(300)).to eq('$300')
      end
    end
  end
  describe '#display_assigned' do
    context 'when the name is under 16 chars' do
      it 'returns the name' do
        @account = create(:account)
        allow(@account).to receive(:assignee).and_return(assignee)
        allow(assignee).to receive(:full_name).and_return('Abe Lincoln')
        allow(@account).to receive(:assigned_to).and_return(1)
        expect(display_assigned(@account)).to eq('Abe Lincoln')
      end
    end
    context 'when the name is over 16 chars' do
      it 'returns the truncated name' do
        @account = create(:account)
        allow(@account).to receive(:assignee).and_return(assignee)
        allow(assignee).to receive(:full_name).and_return('Richard Milhouse Nixon')
        allow(@account).to receive(:assigned_to).and_return(1)
        expect(display_assigned(@account)).to eq('Richard Milho...')
      end
    end
  end
end
