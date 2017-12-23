# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'rubygems/package_task'

Bundler::GemHelper.install_tasks

gemspec = eval(File.read('fat_free_crm.gemspec'))
Gem::PackageTask.new(gemspec) do |p|
  p.gem_spec = gemspec
end
