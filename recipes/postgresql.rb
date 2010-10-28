require File.expand_path('../yum', __FILE__)

namespace :postgresql do

  set :pgdata, "/var/lib/pgsql/data"

  # Installation

  desc "Install postgresql"
  task :install, :roles => :db do
    install_deps
    init_db
    setup_db
    config
  end

  task :install_deps, :roles => :db do
    yum.install( {:base => %w(postgresql postgresql-server postgresql-devel)}, :stable )
  end

  desc "Initialize Database"
  task :init_db, :roles => :db do
    sudo "mkdir -p #{pgdata}"
    sudo "chown -R postgres #{pgdata}"
    sudo "su - postgres -c \'if ! (test -f /var/lib/pgsql/data/pg_hba.conf); then initdb -D #{pgdata}; fi\'"
  end

  desc "Create Database"
  task :create_db, :roles => :db do
    createuser(db_user, db_password)
    createdb(db_name, db_user)
  end

  desc "Start postgres and create database"
  task :setup_db do
    activate
    start
    create_db
  end

  # Configuration

  desc "Create the postgress database.yml"
  task :config do
    database_yml = <<-EOF
production:
  adapter: postgresql
  database: #{db_name}
  username: #{db_user}
  password: #{db_password}
  host:     #{db_host}
  port:     #{db_port}
  schema_search_path: public
  encoding: utf8
  template: template0
    EOF

    put database_yml, "#{deploy_to}/shared/config/database.yml"
  end

  task :symlink do
    sudo "ln -sf #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  task :activate, :roles => :db do
    send(run_method, "/sbin/chkconfig --add postgresql")
    send(run_method, "/sbin/chkconfig postgresql on")
  end

  task :deactivate, :roles => :db do
    send(run_method, "/sbin/chkconfig --del postgresql")
  end

  # Control

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

  task :backup, :roles => :db do
  end

  task :restore, :roles => :db do
  end

end

before "deploy:cold",        "postgresql:install"
after  "deploy:update_code", "postgresql:symlink"

# Imported from Rails Machine gem (Copyright (c) 2006 Bradley Taylor, bradley@railsmachine.com)

def createdb(db, user)
  cmd = "su - postgres -c \'createdb -O #{user} #{db}\'"
  cmd = "if ! (psql -U postgres -l | grep #{db}); then #{cmd}; fi"

  run cmd
end

def createuser(user, password)
  cmd = "su - postgres -c \'createuser -P -D -A -E #{user}\'"
  cmd = "if ! (psql -U postgres -c \'SELECT * from pg_user;\' | grep #{user}); then #{cmd}; fi"

  run cmd do |channel, stream, data|
    if data =~ /^Enter password for new/
      channel.send_data "#{password}\n"
    end
    if data =~ /^Enter it again:/
      channel.send_data "#{password}\n"
    end
    if data =~ /^Shall the new role be allowed to create more new roles?/
      channel.send_data "n\n"
    end
  end
end

def command(sql, database)
  run "psql --command=\"#{sql}\" #{database}"
end
