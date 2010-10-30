namespace :postgresql do

  task :symlink do
    sudo "ln -sf #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Start PostgreSQL"
  task :start, :roles => :db do
    send(run_method, "/etc/init.d/postgresql start")
  end

  desc "Stop PostgreSQL"
  task :stop, :roles => :db do
    send(run_method, "/etc/init.d/postgresql stop")
  end

  desc "Restart PostgreSQL"
  task :restart, :roles => :db do
    send(run_method, "/etc/init.d/postgresql restart")
  end

  desc "Reload PostgreSQL"
  task :reload, :roles => :db do
    send(run_method, "/etc/init.d/postgresql reload")
  end

end

after "deploy:update_code", "postgresql:symlink"
