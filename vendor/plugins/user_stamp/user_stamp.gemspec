Gem::Specification.new do |s|
  s.name              = 'user_stamp'
  s.version           = '1.0.0'
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'Stamp records with a user when they are created and updated'
  s.homepage          = 'http://github.com/jnunemaker/user_stamp'
  s.email             = 'jnunemaker@gmail.com'
  s.authors           = [ 'John Nunemaker' ]
  s.has_rdoc          = false

  s.files             = %w( README Rakefile MIT-LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("rails/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.description       = <<desc
    Rails plugin that makes stamping records with a user when they are 
    created and updated dirt simple. It assumes that your controller has 
    a current_user method. It also assumes that any record being stamped
    has two attributes--creator_id and updater_id. You can override both
    of these assumptions easily.
desc
end
