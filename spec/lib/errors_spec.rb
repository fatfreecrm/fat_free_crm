# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe 'ActiveModel Validation Errors' do
  it 'should render explicit error message if it starts with a caret' do
    class Adam < User
      validates_presence_of :title, message: '^Missing title'
    end

    adam = Adam.create(username: 'adam', email: 'adam@example.com')
    adam.valid?.should == false
    adam.errors[:title].should == [ '^Missing title' ]
    adam.errors.full_messages.should include('Missing title')
  end

  it 'should exhibit default behavior' do
    class Eve < User
      validates_presence_of :title, message: 'missing'
    end

    eve = Eve.create(username: 'eve', email: 'eve@example.com')
    eve.valid?.should == false
    eve.errors[:title].should == [ 'missing' ]
  end
end
