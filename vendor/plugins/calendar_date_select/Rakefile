# -*- ruby -*-


begin
  require 'rubygems'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "calendar_date_select"
    gemspec.version = File.read("VERSION").strip
    gemspec.summary = "Calendar date picker for rails"
    gemspec.description = "Calendar date picker for rails"
    gemspec.email = ""
    gemspec.homepage = "http://github.com/timcharper/calendar_date_select"
    gemspec.authors = ["Shih-gian Lee", "Enrique Garcia Cota (kikito)", "Tim Charper", "Lars E. Hoeg"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

desc "Set the current gem version in the code according to the VERSION file"
task :set_version do
  VERSION=File.read("VERSION").strip
  ["lib/calendar_date_select/calendar_date_select.rb", "public/javascripts/calendar_date_select/calendar_date_select.js"].each do |file|
    abs_file = File.dirname(__FILE__) + "/" + file
    src = File.read(abs_file)
    src = src.map do |line|
      case line
      when /^ *VERSION/                        then "  VERSION = '#{VERSION}'\n"
      when /^\/\/ CalendarDateSelect version / then "// CalendarDateSelect version #{VERSION} - a prototype based date picker\n"
      else
        line
      end
    end.join
    File.open(abs_file, "wb") { |f| f << src }
  end
end
# vim: syntax=Ruby
