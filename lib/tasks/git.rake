namespace :git do
  desc "Install submodule post-merge hook"
  task :install_hook do
    postmerge_hook = ".git/hooks/post-merge"
    File.delete postmerge_hook rescue true
    File.open(postmerge_hook, 'w') do |f|
      f.puts %Q{#!/bin/sh
git submodule update}
    end
    File.chmod 0755, postmerge_hook
    puts "===== Installed post-merge hook. Submodules will now be updated automatically."
  end
end

