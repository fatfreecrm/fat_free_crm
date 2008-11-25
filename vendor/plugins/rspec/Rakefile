# -*- ruby -*-

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rubygems'
require 'hoe'
require 'spec/version'
require 'spec/rake/spectask'

class Hoe
  def extra_deps
    @extra_deps.reject! { |x| Array(x).first == 'hoe' }
    @extra_deps
  end
end

Hoe.new('rspec', Spec::VERSION::STRING) do |p|
  p.summary = Spec::VERSION::SUMMARY
  p.url = 'http://rspec.info/'
  p.description = "Behaviour Driven Development for Ruby."
  p.rubyforge_name = 'rspec'
  p.developer('RSpec Development Team', 'rspec-devel@rubyforge.org')
  p.remote_rdoc_dir = "rspec/#{Spec::VERSION::STRING}"
end

['audit','test','test_deps','default','post_blog'].each do |task|
  Rake.application.instance_variable_get('@tasks').delete(task)
end

task :verify_rcov => [:spec, :stories]
task :default => :verify_rcov

# # Some of the tasks are in separate files since they are also part of the website documentation
load File.dirname(__FILE__) + '/rake_tasks/examples.rake'
load File.dirname(__FILE__) + '/rake_tasks/examples_with_rcov.rake'
load File.dirname(__FILE__) + '/rake_tasks/failing_examples_with_html.rake'
load File.dirname(__FILE__) + '/rake_tasks/verify_rcov.rake'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
  unless ENV['NO_RCOV']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--text-report', '--exclude', "lib/spec.rb,lib/spec/runner.rb,spec\/spec,bin\/spec,examples,\/var\/lib\/gems,\/Library\/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
  end
end

desc "Run all stories"
task :stories do
  ruby "stories/all.rb --colour --format plain"
end

desc "Run failing examples (see failure output)"
Spec::Rake::SpecTask.new('failing_examples') do |t|
  t.spec_files = FileList['failing_examples/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{fn}:#{count}:#{line}"
        end
      end
    end
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO|TBD)/
end

desc "verify_committed, verify_rcov, post_news, release"
task :complete_release => [:verify_committed, :verify_rcov, :post_news, :release]

desc "Verifies that there is no uncommitted code"
task :verify_committed do
  IO.popen('git status') do |io|
    io.each_line do |line|
      raise "\n!!! Do a git commit first !!!\n\n" if line =~ /^#\s*modified:/
    end
  end
end