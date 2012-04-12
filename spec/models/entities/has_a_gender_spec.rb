require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Contact do
  before :each do
    @contact = Contact.new
  end
  
  context 'validate gender' do
    it 'should be invalid if gender is not "m" or "f"' do
      @contact.gender = "a"
      @contact.valid?
      @contact.should have_errors_on(:gender).with_message('is not included in the list')
    end
    
    it 'should be valid if gender is "m"' do
      @contact.gender = "m"
      @contact.valid?
      @contact.should_not have_errors_on(:gender)
    end
    
    it 'should be valid if gender is "f"' do
      @contact.gender = "f"
      @contact.valid?
      @contact.should_not have_errors_on(:gender)
    end
  end
  
  describe '#humanize_gender' do
    it 'should return "Male" for "m"' do
      @contact.gender = 'm'
      @contact.humanize_gender.should == 'Male'
    end
    
    it 'should return "Female" for "f"' do
      @contact.gender = 'f'
      @contact.humanize_gender.should == 'Female'
    end
    
    it 'should return nil for an unkown gender' do
      @contact.gender = 'a'
      @contact.humanize_gender.should be_nil
    end
  end
  
  describe '#gender_select_options' do
    it 'should return a mapping between gender key and readable name' do
      Contact.gender_select_options.should == [['Male', 'm'],
                                       ['Female', 'f']]
    end
  end
end
