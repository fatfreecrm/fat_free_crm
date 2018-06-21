# Usage:
# 1. Build the FFCRM image:
# docker-compose build
# 2. Start the database:
# docker-compose up -d db
# 3. Create the database:
# docker-compose run web rake db:setup
# 4. Start the full application:
# docker-compose up -d
# 5. OPTIONAL: load demo data:
# docker-compose exec web rake ffcrm:demo:load
#
#
# Build from the Ruby 2.4 slim linux image for the base box, which is built on Debian Jesse.
FROM ruby:2.4-slim
LABEL maintainer="William Payne <will@paynelabs.io>"
# Install Dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y imagemagick build-essential tzdata libmysqlclient-dev nodejs && apt-get autoremove -y
# Create the directory from which the production code will be hosted
ENV APP_DIR=/usr/
WORKDIR APP_DIR
# Set the rails environment early on, so that all processes are done with production settings
ENV RAILS_ENV=production
ENV CI=true
ENV DB=mysql
ENV DOCKER=true
# Set the port to serve this application by Puma
ENV PORT=8080
# Copy over the application 
ADD . ./

RUN gem install bundler

RUN mv config/database.docker.yml config/database.yml

RUN bundle install --without development test 
# Finally, precompile the asset pipeline
RUN bundle exec rake assets:precompile

# Publish port 8080, because that's the port we set above in the environment. 
EXPOSE 8080

CMD ["bundle", "exec", "puma -C config/puma.rb"]