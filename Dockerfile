# fig build
# fig run web bundle exec rake db:create db:schema:load ffcrm:demo:load
# fig up

FROM phusion/passenger-ruby21
MAINTAINER Ivan Bianko



ENV HOME /root

CMD ["/sbin/my_init"]

ADD . /home/app/ffcrm
WORKDIR /home/app/ffcrm

RUN cp config/settings.default.yml config/settings.yml
RUN cp config/database.postgres.docker.yml config/database.yml

RUN chown -R app:app /home/app/ffcrm

# Set Rails to run in production
ENV RAILS_ENV production 
ENV RACK_ENV production

RUN sudo -u app bundle install --deployment
# Precompile Rails assets
RUN sudo -u app bundle exec rake assets:precompile

CMD sudo -u app bundle exec unicorn -p $PORT -c ./config/unicorn.rb