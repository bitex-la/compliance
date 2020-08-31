FROM ubuntu:18.04

ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH=$RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TZ=America/Argentina
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake curl git zlib1g-dev \
    libssl-dev libreadline-dev \
    libyaml-dev libxml2-dev \
    libxslt-dev libsqlite3-dev \
    python-dev libxml2-dev \
    libxslt-dev groff zip \
    pkg-config ca-certificates \
    libcurl4-openssl-dev mysql-server libmysqlclient-dev nodejs \
    libmagickwand-dev imagemagick tzdata file \
    redis-server \ 
    && apt-get clean

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv \
    && echo '# rbenv setup' > /etc/profile.d/rbenv.sh \
    && echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
    && echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh \
    && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
    && chmod +x /etc/profile.d/rbenv.sh

ENV RAILS_FOLDER=/usr/local/compliance

# install ruby-build
RUN mkdir /usr/local/rbenv/plugins \
    && git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
    && /usr/local/rbenv/plugins/ruby-build/install.sh \
    && rbenv install 2.5.7 \
    && rbenv global 2.5.7 \
    && gem install bundler \
    && rbenv rehash

# RUN service mysql start && mysql -u root -e "SET Password FOR 'root'@'localhost' = 'example';"
RUN rm -rf /usr/local/bin/rbenv-install

RUN sed -i "s|bind-address.*|skip-networking|g" /etc/mysql/mysql.conf.d/mysqld.cnf

RUN git clone https://github.com/bitex-la/compliance.git /usr/local/compliance \
    && cp /usr/local/compliance/docker/standalone/settings.yml /usr/local/compliance/config/settings.yml \
    && cd /usr/local/compliance && bundle install 

RUN service mysql start \
    && redis-server --daemonize yes --port 0 --unixsocket /tmp/redis.sock --unixsocketperm 775 \
    && cd /usr/local/compliance && bundle exec rails db:setup

EXPOSE 5000

CMD service mysql start \
  && redis-server --daemonize yes --port 0 --unixsocket /tmp/redis.sock --unixsocketperm 775 \
  && cd /usr/local/compliance \
  && git pull origin master \
  && cp /usr/local/compliance/docker/standalone/settings.yml /usr/local/compliance/config/settings.yml \
  && bundle install \
  && bundle exec rake db:migrate \
  && bundle exec rails s -p 5000 -b '0.0.0.0'
