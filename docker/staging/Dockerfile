FROM ruby:3.0.0-alpine as rubyonrails

WORKDIR /web

ENV ALPINE_MIRROR="http://dl-cdn.alpinelinux.org/alpine"

RUN echo "${ALPINE_MIRROR}/v3.13/main" >> /etc/apk/repositories \
  && apk update \
  && apk add util-linux \
  && apk add --no-cache -t .build-dependencies build-base libxml2-dev libxslt-dev \
  && apk add --no-cache libpq libxml2 libxslt nodejs postgresql-client postgresql-dev tini tzdata yarn

ENV RAILS_ENV="staging"

COPY Gemfile* /web

RUN gem install bundler:2.2.21 \
  && bundle lock --add-platform x86_64-linux-musl \
  && bundle config without 'development test' \
  && bundle config deployment true \
  && bundle install -j$(getconf _NPROCESSORS_ONLN)

FROM rubyonrails as builder
WORKDIR /web
COPY . /web

RUN chmod +x bin/rails
RUN bundle exec bin/rails assets:precompile SECRET_KEY_BASE="tmp" \
  && rm -rf node_modules tmp/cache terraform

EXPOSE 3000
