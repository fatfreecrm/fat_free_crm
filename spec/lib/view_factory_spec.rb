# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "fat_free_crm/view_factory"

describe FatFreeCrm::ViewFactory do
  before(:each) do
    FatFreeCrm::ViewFactory.send(:class_variable_set, '@@views', [])
  end

  describe "initialization" do
    before(:each) do
      @view_params = { name: 'brief', title: 'Brief View', icon: 'fa-bars', controllers: ['contacts'], actions: %w[show index] }
    end

    it "should initialize with required parameters" do
      view = FatFreeCrm::ViewFactory.new @view_params
      expect(view.name).to eq('brief')
      expect(view.title).to eq('Brief View')
      expect(view.controllers).to include('contacts')
      expect(view.actions).to include('show')
      expect(view.actions).to include('index')
    end

    it "should register view with ViewFactory" do
      expect(FatFreeCrm::ViewFactory.send(:class_variable_get, '@@views').size).to eq(0)
      FatFreeCrm::ViewFactory.new @view_params
      expect(FatFreeCrm::ViewFactory.send(:class_variable_get, '@@views').size).to eq(1)
    end

    it "should not register the same view twice" do
      FatFreeCrm::ViewFactory.new @view_params
      FatFreeCrm::ViewFactory.new @view_params
      views = FatFreeCrm::ViewFactory.send(:class_variable_get, '@@views')
      expect(views.size).to eq(1)
    end
  end

  describe "views_for" do
    before(:each) do
      @v1 = FatFreeCrm::ViewFactory.new name: 'brief', title: 'Brief View', controllers: ['contacts'], actions: %w[show index]
      @v2 = FatFreeCrm::ViewFactory.new name: 'long', title: 'Long View', controllers: ['contacts'], actions: ['show']
      @v3 = FatFreeCrm::ViewFactory.new name: 'full', title: 'Full View', controllers: ['accounts'], actions: ['show']
    end

    it "should return 'brief' view for ContactsController#index" do
      expect(FatFreeCrm::ViewFactory.views_for(controller: 'contacts', action: 'index')).to eq([@v1])
    end

    it "should return 'brief' and 'long' view for ContactsController#show" do
      views = FatFreeCrm::ViewFactory.views_for(controller: 'contacts', action: 'show')
      expect(views).to include(@v1)
      expect(views).to include(@v2)
    end

    it "should return 'full' view for AccountsController#show" do
      expect(FatFreeCrm::ViewFactory.views_for(controller: 'accounts', action: 'show')).to eq([@v3])
    end

    it "should return no views for TasksController#show" do
      expect(FatFreeCrm::ViewFactory.views_for(controller: 'tasks', action: 'show')).to eq([])
    end
  end
end
