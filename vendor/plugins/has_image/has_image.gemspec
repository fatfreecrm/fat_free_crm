Gem::Specification.new do |s|
  s.name = "has_image"
  s.version = "0.3.0"
  s.date = "2008-10-22"
  s.add_dependency('mini_magick', '>= 1.2.3')
  s.rubyforge_project = 'has-image'  
  s.summary = "Lets you attach images with thumbnails to active record models."
  s.email = 'norman@randomba.org'
  s.homepage = 'http://randomba.org'
  s.description = 'HasImage is a Ruby on Rails gem/plugin that allows you to attach images to ActiveRecord models.'
  s.has_rdoc = true
  s.authors = ['Norman Clarke']
  s.files = [
    "CHANGELOG",
    "FAQ",
    "MIT-LICENSE",
    "README.textile",
    "init.rb",
    "lib/has_image.rb",
    "lib/has_image/processor.rb",
    "lib/has_image/storage.rb",
    "lib/has_image/view_helpers.rb",
    "Rakefile",
    ]
  s.test_files = [
    "test_rails/database.yml",
    "test_rails/fixtures/bad_image.jpg",
    "test_rails/fixtures/image.jpg",
    "test_rails/fixtures/image.png",
    "test_rails/pic_test.rb",
    "test_rails/complex_pic_test.rb",
    "test_rails/schema.rb",
    "test_rails/test_helper.rb",
    "test/processor_test.rb",
    "test/storage_test.rb",
  ]
  s.rdoc_options = ["--main", "--inline-source", "--line-numbers"]
  # s.extra_rdoc_files = ["CHANGELOG", "FAQ"]

end
