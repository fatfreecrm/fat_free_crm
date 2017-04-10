# fig build
# fig run web bundle exec rake db:create db:schema:load ffcrm:demo:load
# fig up

FROM phusion/passenger-ruby24
MAINTAINER Steve Kenworthy

RUN apt-get update \
  && apt-get install -y sudo \
  && apt-get autoremove -y

ENV HOME /root

CMD ["/sbin/my_init"]

ADD . /home/app/ffcrm
WORKDIR /home/app/ffcrm

RUN cp config/database.postgres.docker.yml config/database.yml

RUN chown -R app:app /home/app/ffcrm
RUN sudo -u app bundle install --deployment
