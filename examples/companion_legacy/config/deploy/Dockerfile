# syntax=docker/dockerfile:1

FROM ruby:3.2.2-slim

ENV APP_ROOT=/app \
    BUNDLE_WITHOUT="" \
    BUNDLE_PATH=/usr/local/bundle

WORKDIR ${APP_ROOT}

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential git pkg-config libsqlite3-dev \
 && rm -rf /var/lib/apt/lists/*

COPY . ${APP_ROOT}

WORKDIR ${APP_ROOT}/examples/companion

RUN bundle install

RUN mkdir -p var

EXPOSE 4567 4568 4569

CMD ["bundle", "exec", "ruby", "stack.rb", "main"]
