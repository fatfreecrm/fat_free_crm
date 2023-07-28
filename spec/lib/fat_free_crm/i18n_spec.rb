# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'I18n.t()' do

  class TestController < ActionController::Base
    include FatFreeCRM::I18n
  end

  let(:entity_string) { 'entities' }
  let(:hidden_count) { 10 }
  let(:test_controller) { TestController.new }

  it 'should translate hash arguments' do
    expect(test_controller.t(:not_showing_hidden_entities, entity: entity_string, count: hidden_count))
      .to eq("Not showing 10 hidden entities.")
  end
end
