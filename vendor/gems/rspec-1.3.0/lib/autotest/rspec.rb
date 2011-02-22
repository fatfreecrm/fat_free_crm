require 'autotest'

Autotest.add_hook :initialize do |at|
  at.clear_mappings
  # watch out for Ruby bug (1.8.6): %r(/) != /\//
  at.add_mapping(%r%^spec/.*_spec\.rb$%) { |filename, _|
    filename
  }
  at.add_mapping(%r%^lib/(.*)\.rb$%) { |_, m|
    ["spec/#{m[1]}_spec.rb"]
  }
  at.add_mapping(%r%^spec/(spec_helper|shared/.*)\.rb$%) {
    at.files_matching %r%^spec/.*_spec\.rb$%
  }
end

class RspecCommandError < StandardError; end

class Autotest::Rspec < Autotest
  
  SPEC_PROGRAM = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin', 'spec'))

  def initialize
    super
    self.failed_results_re = /^\d+\)\n(?:\e\[\d*m)?(?:.*?in )?'([^\n]*)'(?: FAILED)?(?:\e\[\d*m)?\n\n?(.*?(\n\n\(.*?)?)\n\n/m
    self.completed_re = /\n(?:\e\[\d*m)?\d* examples?/m
  end

  def consolidate_failures(failed)
    filters = new_hash_of_arrays
    failed.each do |spec, trace|
      if trace =~ /\n(\.\/)?(.*spec\.rb):[\d]+:/
        filters[$2] << spec
      end
    end
    return filters
  end

  def make_test_cmd(files_to_test)
    files_to_test.empty? ? '' :
      "#{ruby} #{SPEC_PROGRAM} --autospec #{normalize(files_to_test).keys.flatten.join(' ')} #{add_options_if_present}"
  end

  def normalize(files_to_test)
    files_to_test.keys.inject({}) do |result, filename|
      result[File.expand_path(filename)] = []
      result
    end
  end

  def add_options_if_present # :nodoc:
    File.exist?("spec/spec.opts") ? "-O #{File.join('spec','spec.opts')} " : ""
  end
end
