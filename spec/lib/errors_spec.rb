# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ActiveModel Validation Errors' do
  it 'should render explicit error message if it starts with a caret' do
    class Adam < User
      validates_presence_of :title, message: '^Missing title'
    end

    adam = Adam.create(username: 'adam', email: 'adam@example.com', password: 'ouchmyrib')
    expect(adam.valid?).to eq(false)
    expect(adam.errors[:title]).to eq(['^Missing title'])
    expect(adam.errors.full_messages[0]).to eq('Missing title')
  end

  it 'should exhibit default behavior' do
    class Eve < User
      validates_presence_of :title, message: 'missing'
    end

    eve = Eve.create(username: 'eve', email: 'eve@example.com', password: 'doyoulikeapples')
    expect(eve.valid?).to eq(false)
    expect(eve.errors[:title]).to eq(['missing'])
    expect(eve.errors.full_messages[0]).to eq('Title missing')
  end
end
