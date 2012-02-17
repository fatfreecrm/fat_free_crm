if defined?(RSpec)
  namespace :spec do
    desc 'Run the acceptance specs in acceptance'
    RSpec::Core::RakeTask.new(:acceptance) do |t|
      t.pattern = 'acceptance/**/*_spec.rb'
    end
    
    task :statsetup do
      if File.exist?('acceptance')
        require 'rails/code_statistics'
        ::STATS_DIRECTORIES << ['Acceptance specs', 'acceptance'] 
        ::CodeStatistics::TEST_TYPES << 'Acceptance specs'
      end
    end
  end
end
