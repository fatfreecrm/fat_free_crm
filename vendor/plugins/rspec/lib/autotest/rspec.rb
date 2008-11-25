require 'autotest'

Autotest.add_hook :initialize do |at|
  at.clear_mappings
  # watch out: Ruby bug (1.8.6):
  # %r(/) != /\//
  at.add_mapping(%r%^spec/.*_spec.rb$%) { |filename, _| 
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

  def initialize
    super
    self.failed_results_re = /^\d+\)\n(?:\e\[\d*m)?(?:.*?in )?'([^\n]*)'(?: FAILED)?(?:\e\[\d*m)?\n(.*?)\n\n/m
    self.completed_re = /\n(?:\e\[\d*m)?\d* examples?/m
  end
  
  def consolidate_failures(failed)
    filters = new_hash_of_arrays
    failed.each do |spec, trace|
      if trace =~ /\n(\.\/)?(.*spec\.rb):[\d]+:\Z?/
        filters[$2] << spec
      end
    end
    return filters
  end

  def make_test_cmd(files_to_test)
    return '' if files_to_test.empty?
    return "#{ruby} -S #{files_to_test.keys.flatten.join(' ')} #{add_options_if_present}"
  end
  
  def add_options_if_present # :nodoc:
    File.exist?("spec/spec.opts") ? "-O spec/spec.opts " : ""
  end
end
