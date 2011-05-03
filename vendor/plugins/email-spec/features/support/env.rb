require 'rubygems'
require 'spec/expectations'

class EmailSpecWorld
  def self.root_dir
    @root_dir ||= File.join(File.expand_path(File.dirname(__FILE__)), "..", "..")
  end

  def root_dir
    EmailSpecWorld.root_dir
  end
end

World do
  EmailSpecWorld.new
end
