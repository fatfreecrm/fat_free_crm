require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EmailsController, "handling GET /emails" do

  before do
    @email = mock_model(Email)
    Email.stub!(:find).and_return([@email])
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all emails" do
    Email.should_receive(:find).with(:all).and_return([@email])
    do_get
  end
  
  it "should assign the found emails for the view" do
    do_get
    assigns[:emails].should == [@email]
  end
end

describe EmailsController, "handling GET /emails.xml" do

  before do
    @email = mock_model(Email, :to_xml => "XML")
    Email.stub!(:find).and_return(@email)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all emails" do
    Email.should_receive(:find).with(:all).and_return([@email])
    do_get
  end
  
  it "should render the found email as xml" do
    @email.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe EmailsController, "handling GET /emails/1" do

  before do
    @email = mock_model(Email)
    Email.stub!(:find).and_return(@email)
  end
  
  def do_get
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show template" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the email requested" do
    Email.should_receive(:find).with("1").and_return(@email)
    do_get
  end
  
  it "should assign the found email for the view" do
    do_get
    assigns[:email].should equal(@email)
  end
end

describe EmailsController, "handling GET /emails/1.xml" do

  before do
    @email = mock_model(Email, :to_xml => "XML")
    Email.stub!(:find).and_return(@email)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the email requested" do
    Email.should_receive(:find).with("1").and_return(@email)
    do_get
  end
  
  it "should render the found email as xml" do
    @email.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe EmailsController, "handling GET /emails/new" do

  before do
    @email = mock_model(Email)
    Email.stub!(:new).and_return(@email)
  end
  
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  it "should create an new email" do
    Email.should_receive(:new).and_return(@email)
    do_get
  end
  
  it "should not save the new email" do
    @email.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new email for the view" do
    do_get
    assigns[:email].should equal(@email)
  end
end

describe EmailsController, "handling GET /emails/1/edit" do

  before do
    @email = mock_model(Email)
    Email.stub!(:find).and_return(@email)
  end
  
  def do_get
    get :edit, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the email requested" do
    Email.should_receive(:find).and_return(@email)
    do_get
  end
  
  it "should assign the found email for the view" do
    do_get
    assigns[:email].should equal(@email)
  end
end

describe EmailsController, "handling POST /emails" do

  before do
    @email = mock_model(Email, :to_param => "1")
    Email.stub!(:new).and_return(@email)
  end
  
  def post_with_successful_save
    @email.should_receive(:save).and_return(true)
    post :create, :email => {}
  end
  
  def post_with_failed_save
    @email.should_receive(:save).and_return(false)
    post :create, :email => {}
  end
  
  it "should create a new email" do
    Email.should_receive(:new).with({}).and_return(@email)
    post_with_successful_save
  end

  it "should redirect to the new email on successful save" do
    post_with_successful_save
    response.should redirect_to(email_url("1"))
  end

  it "should re-render 'new' on failed save" do
    post_with_failed_save
    response.should render_template('new')
  end
end

describe EmailsController, "handling PUT /emails/1" do

  before do
    @email = mock_model(Email, :to_param => "1")
    Email.stub!(:find).and_return(@email)
  end
  
  def put_with_successful_update
    @email.should_receive(:update_attributes).and_return(true)
    put :update, :id => "1"
  end
  
  def put_with_failed_update
    @email.should_receive(:update_attributes).and_return(false)
    put :update, :id => "1"
  end
  
  it "should find the email requested" do
    Email.should_receive(:find).with("1").and_return(@email)
    put_with_successful_update
  end

  it "should update the found email" do
    put_with_successful_update
    assigns(:email).should equal(@email)
  end

  it "should assign the found email for the view" do
    put_with_successful_update
    assigns(:email).should equal(@email)
  end

  it "should redirect to the email on successful update" do
    put_with_successful_update
    response.should redirect_to(email_url("1"))
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe EmailsController, "handling DELETE /email/1" do

  before do
    @email = mock_model(Email, :destroy => true)
    Email.stub!(:find).and_return(@email)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the email requested" do
    Email.should_receive(:find).with("1").and_return(@email)
    do_delete
  end
  
  it "should call destroy on the found email" do
    @email.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the emails list" do
    do_delete
    response.should redirect_to(emails_url)
  end
end
