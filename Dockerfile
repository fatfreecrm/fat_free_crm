# fig build
# fig run web bundle exec rake db:create db:schema:load ffcrm:demo:load
# fig up

FROM phusion/passenger-ruby21
MAINTAINER Ivan Bianko

ENV HOME /root
CMD ["/sbin/my_init"]

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app 
WORKDIR /app

RUN chown -R app:app /home/app

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./ 
RUN sudo -u app bundle install --jobs 20 --retry 5 --without development test

# Set Rails to run in production
ENV RAILS_ENV production 
ENV RACK_ENV production

# Copy the main application.
COPY . ./

# Precompile Rails assets
RUN sudo -u app bundle exec rake assets:precompile

RUN cp config/settings.default.yml config/settings.yml
RUN cp config/database.postgres.docker.yml config/database.yml


RUN sudo -u app bundle exec rake assets:precompile
CMD sudo -u app bundle exec unicorn -p $PORT -c ./config/unicorn.rb