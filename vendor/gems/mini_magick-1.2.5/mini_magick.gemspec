# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mini_magick}
  s.version = "1.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Corey Johnson"]
  s.date = %q{2009-05-27}
  s.email = %q{probablycorey@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/image_temp_file.rb",
     "lib/mini_magick.rb",
     "mini_magick.gemspec",
     "test/actually_a_gif.jpg",
     "test/animation.gif",
     "test/command_builder_test.rb",
     "test/image_temp_file_test.rb",
     "test/image_test.rb",
     "test/leaves.tiff",
     "test/not_an_image.php",
     "test/simple.gif",
     "test/trogdor.jpg"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/probablycorey/mini_magick}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mini-magick}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Manipulate images with minimal use of memory.}
  s.test_files = [
    "test/command_builder_test.rb",
     "test/image_temp_file_test.rb",
     "test/image_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
