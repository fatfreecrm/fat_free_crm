Story: before suite
	As a developer using rspec
	I want to define before blocks in the global configuration
	So that I can define global things globally
	
	Scenario: running with ruby
	
		Given the file ../resources/spec/before_blocks_example.rb
		
    When I run it with the ruby interpreter

		Then the stdout should match "3 examples, 0 failures"
		
	Scenario: running with spec

		Given the file ../resources/spec/before_blocks_example.rb

    When I run it with the spec script

		Then the stdout should match "3 examples, 0 failures"
					