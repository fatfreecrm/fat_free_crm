FROM phusion/passenger-ruby21
MAINTAINER Ashwin Phatak "ashwinpphatak@gmail.com"

ENV HOME /root

CMD ["/sbin/my_init"]

ADD . /home/app/ffcrm
WORKDIR /home/app/ffcrm

RUN cp config/database.postgres.docker.yml config/database.yml

RUN chown -R app:app /home/app/ffcrm
RUN sudo -u app bundle install --deployment
