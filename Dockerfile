# Usage:
# docker volume create pgdata
# docker volume create gems
# docker-compose up
# docker-compose exec web bundle exec rake db:create db:schema:load ffcrm:demo:load

FROM ruby:3.3

LABEL author="Steve Kenworthy"

ENV HOME /home/app

RUN mkdir -p $HOME

WORKDIR $HOME

ADD . $HOME
RUN apt-get update && \
	apt-get install -y imagemagick tzdata && \
	apt-get autoremove -y && \
	cp config/database.postgres.docker.yml config/database.yml && \
	gem install bundler && \
	bundle config set --local deployment 'true' && \
	bundle install --deployment && \
	bundle exec rails assets:precompile

CMD ["bundle","exec","rails","s"]

EXPOSE 3000

# # Usage:
# # docker volume create pgdata
# # docker volume create gems
# # docker-compose up
# # docker-compose exec web bundle exec rake db:create db:schema:load ffcrm:demo:load assets:precompile

# FROM phusion/passenger-ruby24
# MAINTAINER Steve Kenworthy

# ENV HOME /home/app

# ADD . /home/app
# WORKDIR /home/app

# RUN apt-get update \
#   && apt-get install -y imagemagick firefox tzdata \
#   && apt-get autoremove -y \
#   && cp config/database.postgres.docker.yml config/database.yml \
#   && chown -R app:app /home/app \
#   && rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default \
#   && cp .docker/nginx/sites-enabled/ffcrm.conf /etc/nginx/sites-enabled/ffcrm.conf \
#   && bundle install --deployment
