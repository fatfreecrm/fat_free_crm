require 'spec_helper'

describe LDAPAccess do

  describe 'authenticate' do
    before :each do
      stub_ldap_config()
    end

    it "should call connect to get a connection" do
      LDAPAccess.should_receive(:connect).and_return( mock("LDAP", :bind_as => true ) )
      LDAPAccess.authenticate('user', 'password')
    end

    it "should call bind_as with the provided uid and password" do
      ldap = mock("LDAP")
      ldap.should_receive(:bind_as).with(hash_including(:filter => '(uid=user.name)', :password => 'secret')).and_return(true)
      LDAPAccess.stub!(:connect).and_return( ldap )
      LDAPAccess.authenticate('user.name', 'secret')
    end

    it "should get the search_base and user_filter from the Config" do
      LDAPAccess::Config.should_receive(:search_base).and_return('dc=example,dc=com')
      LDAPAccess::Config.should_receive(:user_filter).and_return('(uid=%s)')
      LDAPAccess.stub!(:connect).and_return(mock("LDAP", :bind_as => true ))
      LDAPAccess.authenticate('user', 'password')
    end

    it "should call bind_as with the search_base and user_filter from the Config" do
      ldap = mock("LDAP")
      ldap.should_receive(:bind_as).with(hash_including(:base => 'dc=example,dc=com', :filter => '(uid=user)')).and_return(true)
      LDAPAccess.stub!(:connect).and_return( ldap )
      LDAPAccess.authenticate('user', 'password')
    end

    it "should return false if bind_as call returns false" do
      LDAPAccess.stub!(:connect).and_return(mock("LDAP", :bind_as => false ))
      LDAPAccess.authenticate('user', 'password').should be_false
    end

    it "should return true if bind_as call returns results" do
      result_hash = {:dn => 'uid=user,dc=example,dc=com', :uid => 'user'}
      LDAPAccess.stub!(:connect).and_return(mock("LDAP", :bind_as => [result_hash] ))
      LDAPAccess.authenticate('user', 'password').should be_true
    end
  end

  describe 'get_user_details' do
    before :each do
      stub_ldap_config()
    end

    it "should call connect to get a connection" do
      LDAPAccess.should_receive(:connect).and_return( mock("LDAP", :search => []))
      LDAPAccess.get_user_details('test.user')
    end

    it "should call search with the provided uid" do
      ldap = mock('LDAP')
      ldap.should_receive(:search).with( hash_including( :filter => '(uid=test.user)' ) ).and_return([])
      LDAPAccess.stub!(:connect).and_return( ldap )
      LDAPAccess.get_user_details('test.user')
    end

    it "should get the search_base and user_filter from the Config" do
      LDAPAccess::Config.should_receive(:search_base).and_return('dc=example,dc=com')
      LDAPAccess::Config.should_receive(:user_filter).and_return('(uid=%s)')
      LDAPAccess.stub!(:connect).and_return(mock("LDAP", :search => [] ))
      LDAPAccess.get_user_details('test.user')
    end

    it "should call search with the search_base and user_filter from the config" do
      ldap = mock("LDAP")
      ldap.should_receive(:search).with(hash_including(:base => 'dc=example,dc=com', :filter => '(uid=test.user)')).and_return([])
      LDAPAccess.stub!(:connect).and_return( ldap )
      LDAPAccess.get_user_details('test.user')
    end

    it "should return nil if no results found" do
      LDAPAccess.stub!(:connect).and_return( mock("LDAP", :search => []))
      LDAPAccess.get_user_details('test.user').should be_nil
    end

    it "should return a hash of details when a result found" do
      LDAPAccess.stub!(:connect).and_return( mock("LDAP", :search => [stub_ldap_entry()] ) )
      details = LDAPAccess.get_user_details('test.user')
      details.should be_a(Hash)
      details[:mail].should == 'test.user@example.com'
      details[:displayname].should == 'Test User'
    end

    it "should return a hash of the first result's details if more than one result found" do
      LDAPAccess.stub!(:connect).and_return( mock("LDAP", :search => [stub_ldap_entry(), stub_ldap_entry(:dn => ['uid=test.user,ou=test,dc=example,dc=com'])] ) )
      details = LDAPAccess.get_user_details('test.user')
      details.should be_a(Hash)
      details[:dn].should == 'uid=test.user,dc=example,dc=com'
    end

    it "should dup the result values to prevent serialization errors" do
      mail = "test.user@example.com"
      mail.should_receive(:dup).and_return('dup.user@example.com')
      LDAPAccess.stub!(:connect).and_return( mock("LDAP", :search => [stub_ldap_entry(:mail => [mail])] ) )
      details = LDAPAccess.get_user_details('test.user')
      details.should be_a(Hash)
      details[:mail].should == 'dup.user@example.com'
    end

    def stub_ldap_entry(options = {})
      {
        :mail => ['test.user@example.com'],
        :objectclass => ['organizationalPerson', 'inetOrgPerson'],
        :uid => ['test.user'],
        :telephonenumber => ['+44 7890123456'],
        :cn => ['Test User'],
        :userpassword => ["{SHA}1hjGSLBIHmbdLGniQAzrOhSQu7w="],
        :sn => ['User'],
        :dn => ['uid=test.user,dc=example,dc=com'],
        :displayname => ['Test User'],
        :givenname => ['Test']
      }.merge(options)
    end
  end

  describe 'connect' do
    it "should get the params from the Config" do
      LDAPAccess::Config.should_receive(:host).and_return('test.host')
      LDAPAccess::Config.should_receive(:port).and_return(389)
      LDAPAccess::Config.should_receive(:ssl).and_return(false)
      LDAPAccess::Config.should_receive(:bind_dn).and_return('uid=admin,dc=example,dc=com')
      LDAPAccess::Config.should_receive(:bind_passwd).and_return('secret')
      Net::LDAP.stub!(:new).and_return(:wibble)
      LDAPAccess.send(:connect)
    end

    it "should create a new Net::LDAP object with the relevant params" do
      stub_ldap_config()
      Net::LDAP.should_receive(:new).with( {
              :host => 'test.host',
              :port => 389,
              :encryption => nil,
              :auth => {
                :method => :simple,
                :username => 'uid=admin,dc=example,dc=com',
                :password => 'secret'
              }
            } ).and_return(:wibble)
      LDAPAccess.send(:connect).should == :wibble
    end

    it "should create a new Net::LDAP object with SSL when requested" do
      stub_ldap_config()
      LDAPAccess::Config.stub!(:ssl).and_return(true)
      Net::LDAP.should_receive(:new).with( hash_including(:encryption => :simple_tls)).and_return(:wibble)
      LDAPAccess.send(:connect).should == :wibble
    end
  end

  def stub_ldap_config()
    LDAPAccess::Config.stub!(:host).and_return('test.host')
    LDAPAccess::Config.stub!(:port).and_return(389)
    LDAPAccess::Config.stub!(:ssl).and_return(false)
    LDAPAccess::Config.stub!(:bind_dn).and_return('uid=admin,dc=example,dc=com')
    LDAPAccess::Config.stub!(:bind_passwd).and_return('secret')
    LDAPAccess::Config.stub!(:search_base).and_return('dc=example,dc=com')
    LDAPAccess::Config.stub!(:user_filter).and_return('(uid=%s)')
  end
end

describe LDAPAccess::Config do
  describe "stubbed configuration" do
    before :each do
      load 'lib/ldap_access.rb' # Clear the cached config
    end
    after :all do
      load 'lib/ldap_access.rb' # Clear the cached config
    end

    describe "loading the config file" do
      it "should load the config from the file" do
        YAML.should_receive(:load_file).with(File.join(RAILS_ROOT, %w(config ldap.yml))).and_return( {"test" => :wibble} )
        LDAPAccess::Config.send(:config).should == :wibble
      end

      it "should only load it once" do
        YAML.stub!(:load_file).and_return( {"test" => :wibble} )

        LDAPAccess::Config.send(:config)
        YAML.should_not_receive(:load_file)
        LDAPAccess::Config.send(:config).should == :wibble
      end
    end

    describe "getting values in the file" do
      before :each do
        YAML.stub!(:load_file).and_return( "test" => {
                          'test_string' => "string",
                          'test_array' => ["one", "two"],
                          'test_hash' => {"one" => "1", "two" => "2"}  } )
      end

      it "should raise method missing for a non-existent key" do
        lambda do
          LDAPAccess::Config.non_existent
        end.should raise_error(NoMethodError)
      end

      it "should return the value if the key exists" do
        LDAPAccess::Config.test_string.should == "string"
      end

      it "should return array values" do
        LDAPAccess::Config.test_array.should == ["one", "two"]
      end

      it "should return hash values" do
        LDAPAccess::Config.test_hash.should == {"one" => "1", "two" => "2"}
      end
    end
  end

  describe "actual configuration" do
    before :each do
      yml = YAML.load_file(File.join(RAILS_ROOT, %w(config ldap.yml.example)))
      YAML.stub!(:load_file).with(File.join(RAILS_ROOT, %w(config ldap.yml))).and_return( yml )
    end
    after :all do
      load 'lib/ldap_access.rb' # Clear the cached config
    end
    %w(host port ssl bind_dn bind_passwd search_base user_filter).each do |attribute|
      it "should have parameter #{attribute}" do
        LDAPAccess::Config.send(attribute.to_sym).should_not be_blank
      end
    end
  end
end