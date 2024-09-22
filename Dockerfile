FROM ruby:3.2-alpine

WORKDIR /app

RUN apk add --no-cache build-base libcurl curl-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY benchmark.rb ./
COPY README.md ./

CMD ["ruby", "benchmark.rb"]