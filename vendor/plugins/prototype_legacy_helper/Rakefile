require 'rake'
require 'rake/testtask'
 
desc 'Default: run unit tests.'
task :default => :test
 
Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
