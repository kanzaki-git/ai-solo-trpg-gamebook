FROM ruby:3.3.6

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      postgresql-client \
      libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile /app/Gemfile

RUN bundle install

COPY . /app
