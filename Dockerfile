# fig build
# fig run web bundle exec rake db:create db:schema:load ffcrm:demo:load
# fig up

FROM phusion/passenger-ruby21
MAINTAINER Steve Kenworthy

ENV HOME /root

CMD ["/sbin/my_init"]

ADD . /home/app/ffcrm
WORKDIR /home/app/ffcrm

RUN cp config/database.postgres.docker.yml config/database.yml

RUN chown -R app:app /home/app/ffcrm
RUN sudo -u app bundle install --deployment
