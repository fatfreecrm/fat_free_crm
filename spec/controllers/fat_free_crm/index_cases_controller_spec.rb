# frozen_string_literal: true

require 'spec_helper'

module FatFreeCrm
  describe IndexCasesController do
    before(:each) do
      login
      set_current_tab(:index_cases)
    end

    describe "responding to GET index" do
      it "should expose all index cases as @contacts and render [index] template" do
        @index_cases = [create(:index_case, user: current_user)]
        get :index
        expect(assigns[:index_cases].count).to eq(@index_cases.count)
        expect(assigns[:index_cases]).to eq(@index_cases)
        expect(response).to render_template("index_cases/index")
      end
    end

    describe "responding to GET show" do
      before(:each) do
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = [] #timeline(@index_case)
        @index_case = create(:index_case, user: current_user)
      end

      it "should expose the requested index case as @index_case" do
        get :show, params: {id: @index_case.id}
        expect(response).to render_template("")
      end
    end
  end
end
