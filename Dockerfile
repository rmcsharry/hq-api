FROM ruby:2.4.3-alpine3.7

RUN apk update && apk add build-base postgresql postgresql-dev git less make

RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN bundle install

# Clean up
RUN apk del build-base

COPY . /app/

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint.sh"]
