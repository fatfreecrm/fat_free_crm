#! /bin/bash

sudo add-apt-repository -y ppa:mozillateam/ppa
sudo apt-get update
sudo apt install libpq-dev # Not strictly needed, but easier than explaining to users to constantly pass DB=sqlite

# TODO: https://gist.github.com/jfeilbach/78d0ef94190fb07dee9ebfc34094702f
sudo apt-get install firefox 

bundle

cp config/database.sqlite.yml config/database.yml

bundle exec rake db:create
bundle exec rake db:migrate