#! /bin/bash

sudo add-apt-repository -y ppa:mozillateam/ppa

echo -e "Package: firefox*\nPin: release o=LP-PPA-mozillateam-ppa\nPin-Priority: 550\n\nPackage: firefox*\nPin: release o=Ubuntu\nPin-Priority: -1" | sudo tee /etc/apt/preferences.d/99-mozillateamppa

cp script/sample_hooks/pre-commit/ .git/hooks/

sudo apt-get update

sudo apt install -y libpq-dev # Not strictly needed, but easier than explaining to users to constantly pass DB=sqlite
sudo apt install -y firefox 
sudo apt install -y codespell

bundle

cp config/database.sqlite.yml config/database.yml

bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake ffcrm:demo:load

bundle exec rails s -b 0.0.0.0