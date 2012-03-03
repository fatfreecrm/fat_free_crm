require 'rubygems/package_task'

Bundler::GemHelper.install_tasks

gemspec = eval(File.read('fat_free_crm.gemspec'))
Gem::PackageTask.new(gemspec) do |p|
  p.gem_spec = gemspec
end
