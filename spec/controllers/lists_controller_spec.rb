# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe ListsController do
  before(:each) do
    login
  end

  let(:list_url) { "/contacts?q%5Bs%5D%5B0%5D%5Bname%5D=&q%5Bs%5D%5B0%5D%5Bdir%5D=asc&q%5Bg%5D%5B0%5D%5Bm%5D=and&q%5Bg%5D%5B0%5D%5Bc%5D%5B0%5D%5Ba%5D%5B0%5D%5Bname%5D=first_name&q%5Bg%5D%5B0%5D%5Bc%5D%5B0%5D%5Bp%5D=cont&q%5Bg%5D%5B0%5D%5Bc%5D%5B0%5D%5Bv%5D%5B0%5D%5Bvalue%5D=test&distinct=1&page=1" }

  describe "global list items" do
    let(:list_name) { "Global list item" }
    let(:is_global) { "1" }
    it "creating should be successful" do
      post :create, params: { list: { name: list_name, url: list_url }, is_global: is_global }, xhr: true
      expect(assigns(:list).persisted?).to eql(true)
      expect(response).to render_template("lists/create")
    end
    it "updating should be successful" do
      @list = List.create!(name: list_name, url: "/test")
      post :create, params: { list: { name: list_name, url: list_url }, is_global: is_global }, xhr: true
      expect(assigns(:list).persisted?).to eql(true)
      expect(@list.reload.url).to eql(list_url)
      expect(response).to render_template("lists/create")
    end
    it "delete list item" do
      @list = List.create!(name: list_name, url: "/test")
      delete :destroy, params: { id: @list.id }, xhr: true
      expect { List.find(@list.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to render_template("lists/destroy")
    end
  end

  describe "personal list items" do
    let(:list_name) { "Personal list item" }
    let(:is_global) { "0" }

    it "creating should be successful" do
      post :create, params: { list: { name: list_name, url: list_url }, is_global: is_global }, xhr: true
      expect(assigns(:list).persisted?).to eql(true)
      expect(response).to render_template("lists/create")
    end
  end
end
