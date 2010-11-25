namespace :git do
  desc "Install git submodule hooks and commands for easier development."
  task :install_hooks do
    postmerge_hook = ".git/hooks/post-merge"

    File.delete postmerge_hook rescue true
    File.open(postmerge_hook, 'w') do |f|
      f.puts %Q{#!/bin/sh
git submodule update}
    end
    File.chmod 0755, postmerge_hook
    puts "=== Installed post-merge hook.\n    (Submodules will now be updated automatically.)"

    submodules = File.open('.gitmodules', 'r').read.split("\n").map {|l|
                     l[/submodule "(.*)"/, 1] }.compact

    submodules.each do |submodule|
      submodule_name = submodule.split("/").last
      xpush_cmd = "!git push && cd ../../.. && git add #{submodule} && \
git commit -m 'Updated #{submodule_name} submodule'"
      system("cd #{submodule} && git config alias.xpush \"#{xpush_cmd}\"")
    end

    puts "=== Installed `git xpush` command on all submodules.\n    (Use it to push the submodule and commit the change to the superproject.)"
  end
end

