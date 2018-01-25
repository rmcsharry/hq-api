FROM ruby:2.4.3-alpine3.7

RUN apk update && apk add build-base postgresql-dev

RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN bundle install

# Clean up
RUN apk del build-base

COPY . /app/

EXPOSE 3000
CMD bundle exec rails s -p 3000 -b 0.0.0.0
