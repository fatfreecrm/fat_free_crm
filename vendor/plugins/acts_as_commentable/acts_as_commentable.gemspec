Gem::Specification.new do |s|
  s.name     = "acts_as_commentable"
  s.version  = "1.0.0"
  s.date     = "2008-10-30"
  s.summary  = "Polymorphic comments Rails plugin"
  s.email    = "jimiray@mac.com"
  s.homepage = "http://github.com/jimiray/acts_as_commentable"
  s.description = "Polymorphic comments Rails plugin"
  s.has_rdoc = true
  s.authors  = ["Jack Dempsey", "Xelipe"] 
  s.files    = ["CHANGELOG", 
		"MIT-LICENSE", 
		"README",
		"Rakefile", 
		"acts_as_commentable.gemspec", 
                "init.rb",
                "install.rb",
		"lib/acts_as_commentable.rb", 
		"lib/comment.rb"]
  s.test_files = ["test/acts_as_commentable_test.rb"]
  s.rdoc_options = ["--main", "README"]
end
