require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ActiveModel Validation Errors' do
  it 'should render explicit error message if it starts with a caret' do
    class Adam < User
      validates_presence_of :title, :message => '^Missing title'
    end

    adam = Adam.create(:username => 'adam', :email => 'adam@example.com')
    adam.valid?.should == false
    adam.errors[:title].should == [ '^Missing title' ]
    adam.errors.full_messages[0].should == 'Missing title'
  end

  it 'should exhibit default behavior' do
    class Eve < User
      validates_presence_of :title, :message => 'missing'
    end

    eve = Eve.create(:username => 'eve', :email => 'eve@example.com')
    eve.valid?.should == false
    eve.errors[:title].should == [ 'missing' ]
    eve.errors.full_messages[0].should == 'Title missing'
  end
end