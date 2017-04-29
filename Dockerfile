# Usage:
# docker-compose up
# docker-compose exec web bundle exec rake db:create db:schema:load ffcrm:demo:load assets:precompile

FROM phusion/passenger-ruby24
MAINTAINER Steve Kenworthy

ENV HOME /home/app

ADD . /home/app
WORKDIR /home/app

RUN apt-get update \
  && apt-get install -y imagemagick firefox \
  && apt-get autoremove -y \
  && cp config/database.postgres.docker.yml config/database.yml \
  && chown -R app:app /home/app \
  && rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default \
  && cp .docker/nginx/sites-enabled/ffcrm.conf /etc/nginx/sites-enabled/ffcrm.conf \
  && bundle install --deployment
