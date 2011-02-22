require 'rdoc/rdoc'
##
# Build the rdoc documentation. Also, try to build the RI documentation.
#
def build_rdoc(options)
  RDoc::RDoc.new.document(options)
rescue RDoc::RDocError => e
  $stderr.puts e.message
rescue Exception => e
  $stderr.puts "Couldn't build RDoc documentation\n#{e.message}"
end

def build_ri(files)
  RDoc::RDoc.new.document(["--ri-site", "--merge"] + files)
rescue RDoc::RDocError => e
  $stderr.puts e.message
rescue Exception => e
  $stderr.puts "Couldn't build Ri documentation\n#{e.message}"
end

def run_tests(test_list)
  return if test_list.empty?

  require 'test/unit/ui/console/testrunner'
  $:.unshift "lib"
  test_list.each do |test|
    next if File.directory?(test)
    require test
  end

  tests = []
  ObjectSpace.each_object { |o| tests << o if o.kind_of?(Class) }
  tests.delete_if { |o| !o.ancestors.include?(Test::Unit::TestCase) }
  tests.delete_if { |o| o == Test::Unit::TestCase }

  tests.each { |test| Test::Unit::UI::Console::TestRunner.run(test) }
  $:.shift
end

rdoc  = %w(--main README.txt --line-numbers)
ri    = %w(--ri-site --merge)
dox   = %w(README.txt History.txt lib)
build_rdoc rdoc + dox
build_ri ri + dox
#run_tests Dir["test/**/*"]
