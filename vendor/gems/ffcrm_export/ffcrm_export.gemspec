$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ffcrm_export/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ffcrm_export"
  s.version     = FfcrmExport::VERSION
  s.authors     = ["Cody Swann"]
  s.email       = ["cody@gunnertech.com"]
  s.homepage    = "http://github.com/gunnertech/ffcrm_export"
  s.summary     = "Adds export functionality to FatFree CRM"
  s.description = "Adds export functionality to FatFree CRM"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  s.add_dependency "squeel", "~> 1.1.1"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
