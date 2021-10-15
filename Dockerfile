FROM ruby:2.5.7

RUN mkdir /src && \
    gem install bundler

COPY ./ /src

WORKDIR /src

ENV RAILS_ENV=staging

RUN mv ./dockerize_needed_files/appsignal.yml ./config/appsignal.yml && \
    mv ./dockerize_needed_files/secrets.yml ./config/secrets.yml && \
    mv ./dockerize_needed_files/database.yml ./config/database.yml && \
    mv ./dockerize_needed_files/settings.yml ./config/settings.yml && \
    bundle install --without test development && \
    bundle exec rails assets:precompile

CMD bundle exec puma -C ./config/puma.rb
