# Usage:
# docker volume create pgdata
# docker volume create gems
# docker-compose up
# docker-compose exec web bundle exec rake db:create db:schema:load ffcrm:demo:load

FROM ruby:3.3

LABEL author="Steve Kenworthy"

ENV HOME=/home/app

RUN mkdir -p $HOME

WORKDIR $HOME

ADD . $HOME

# Copy wait-for-it.sh to a location in the container
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Update package index
RUN apt-get update

# Install imagemagick and tzdata
RUN apt-get install -y imagemagick tzdata

# Clean up unnecessary packages
RUN apt-get autoremove -y

# Copy the database configuration file (ensure this file exists)
RUN cp config/database.postgres.docker.yml config/database.yml

# Install Bundler
RUN gem install bundler

# Set up bundle config for deployment
RUN bundle config set --local deployment 'true'

# Install Ruby gems
RUN bundle install --deployment

# Remove asset precompile command; it will run via Docker Compose later
# CMD ["bundle", "exec", "rails", "assets:precompile"]

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]

EXPOSE 3000
