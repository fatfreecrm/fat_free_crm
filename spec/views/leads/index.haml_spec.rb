require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index" do
  include LeadsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Lead.per_page
    assign :sort_by,  Lead.sort_by
    assign :ransack_search, Lead.search
    login_and_assign
  end

  it "should render list of accounts if list of leads is not empty" do
    assign(:leads, [ FactoryGirl.create(:lead) ].paginate(:page => 1, :per_page => 20))

    render
    view.should render_template(:partial => "_lead")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no leads" do
    assign(:leads, [].paginate(:page => 1, :per_page => 20))

    render
    view.should_not render_template(:partial => "_leads")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

end
