require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/index_cases/_new" do

    before do
      login
      assign(:index_case, create(:index_case))

    it "should render [create index_case] form" do
      render
      expect(view).to render_template(partial: "fat_free_crm/index_cases/_top_section")
      expect(view).to render_template(partial: "fat_free_crm/index_cases/_extra")
    end
  end
end
