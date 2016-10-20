require 'globby'
require 'tmpdir'
require 'fileutils'

describe Globby do
  around do |example|
    gitignore_test { example.run }
  end

  describe ".select" do
    it "should match .gitignore perfectly" do
      rules = prepare_gitignore
      expect(Globby.select(rules.split(/\n/))).to eq(all_files - git_files - untracked)
    end
  end

  describe ".reject" do
    it "should match the inverse of .gitignore, plus .git" do
      rules = prepare_gitignore
      expect(Globby.reject(rules.split(/\n/))).to eq(git_files + untracked)
    end
  end

  def gitignore_test
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        prepare_files
        `git init .`
        yield
      end
    end
  end

  def prepare_gitignore
    ignore = <<-IGNORE.gsub(/^ +/, '')
      # here we go...

      # some dotfiles
      .hidden

      # html, but just in the root
      /*.html

      # all rb files anywhere
      *.rb

      # except rb files immediately under foobar
      !foobar/*.rb

      # ooh look **
      /a/**/*.yuss

      # this will match foo/bar but not bar
      bar/

      # this will match nothing
      foo*bar/baz.pdf

      # this will match baz/ and foobar/baz/
      baz

      # check reinclusion
      /spec/*
      !/spec/noignore
    IGNORE
    File.open('.gitignore', 'w'){ |f| f.write ignore }
    ignore
  end

  def prepare_files
    files = <<-FILES.strip.split(/\s+/)
      .gitignore
      foo.rb
      foo.html
      bar
      baz/lol.txt
      foo/.hidden
      foo/bar.rb
      foo/bar.html
      foo/bar/baz.pdf
      foobar/.hidden
      foobar/baz.txt
      foobar/baz.rb
      foobar/baz/lol.wut
      a/a.yuss
      a/a/a/a/a.yuss
      spec/nope
      spec/noignore
    FILES
    files.each do |file|
      FileUtils.mkdir_p File.dirname(file)
      FileUtils.touch file
    end
  end

  def untracked
    `git status -uall --porcelain`.gsub(/^\?\? /m, '').split(/\n/)
  end

  def git_files
    Dir.glob('.git/**/*', File::FNM_DOTMATCH).
      select{ |f| File.symlink?(f) || File.file?(f) }.sort
  end

  def all_files
    Dir.glob('**/*', File::FNM_DOTMATCH).
      select{ |f| File.symlink?(f) || File.file?(f) }.sort
  end
end
