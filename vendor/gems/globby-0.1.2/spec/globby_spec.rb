require 'globby'

describe Globby do
  it "should support chaining" do
    files = files(%w{foo/bar.rb foo/baz.rb foo/c/bar.html foo/c/c/bar.rb})
    expect(Globby.select(%w{*rb}, files).
                  reject(%w{baz*}).
                  select(%w{c})).to eq %w{foo/c/c/bar.rb}
  end

  describe ".select" do
    context "a blank line" do
      it "should return nothing" do
        files = files("foo")
        expect(Globby.select([""], files)).to eq []
      end
    end

    context "a comment" do
      it "should return nothing" do
        files = files("foo")
        expect(Globby.select(["#"], files)).to eq []
      end
    end

    context "a pattern ending in a slash" do
      it "should return a matching directory's contents" do
        files = files(%w{foo/bar/baz foo/bar/baz2})
        expect(Globby.select(%w{bar/}, files)).to eq %w{foo/bar/baz foo/bar/baz2}
      end

      it "should ignore symlinks and regular files" do
        files = files(%w{foo/bar bar/baz})
        expect(Globby.select(%w{bar/}, files)).to eq %w{bar/baz}
      end
    end

    context "a pattern starting in a slash" do
      it "should return only root glob matches" do
        files = files(%w{foo/bar bar/foo})
        expect(Globby.select(%w{/foo}, files)).to eq %w{foo/bar}
      end
    end

    context "a pattern with a *" do
      it "should return matching files" do
        files = files(%w{foo/bar foo/baz})
        expect(Globby.select(%w{*z}, files)).to eq %w{foo/baz}
      end

      it "should not glob slashes" do
        files = files(%w{foo/bar foo/baz})
        expect(Globby.select(%w{foo*bar}, files)).to eq []
      end
    end

    context "a pattern with a ?" do
      it "should return matching files" do
        files = files(%w{foo/bar foo/baz})
        expect(Globby.select(%w{b?z}, files)).to eq %w{foo/baz}
      end

      it "should not glob slashes" do
        files = files(%w{foo/bar foo/baz})
        expect(Globby.select(%w{foo?bar}, files)).to eq []
      end
    end

    context "a pattern with a **" do
      it "should match directories recursively" do
        files = files(%w{foo/bar foo/baz foo/c/bar foo/c/c/bar})
        expect(Globby.select(%w{foo/**/bar}, files)).to eq %w{foo/bar foo/c/bar foo/c/c/bar}
      end
    end

    context "a pattern with bracket expressions" do
      it "should return matching files" do
        files = files(%w{boo fob f0o foo/bar poo/baz})
        expect(Globby.select(%w{[e-g][0-9[:alpha:]][!b]}, files)).to eq %w{f0o foo/bar}
      end
    end
  end

  def files(files)
    files = Array(files)
    files.sort!
    dirs = files.grep(/\//).map(&:dup).inject([]) { |ary, file|
      ary << file while file.sub!(/[^\/]+\z/, '')
      ary
    }.uniq.sort
    Globby::GlObject.new files, dirs
  end
end
