# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: importers
#
#  id              :integer         not null, primary key
#  filename        :string(64)      default(""), not null
#  md5sum          :string(32)      default(""), not null
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.describe Importer, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
