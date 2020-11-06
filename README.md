# README

## Install pre-requisites
- [ ] Install [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
- [ ] Setup a local mySQL server
- [ ] Setup a local Redis
- [ ] Install dependencies and setup development tools
  ```
    bundle install
  ```

## Environment variables
- [ ] Rename config/settings.example.yml file to config/settings.yml and set the following variables:

  - For Mysql

    - mysql.username: username of MySQL user
    - mysql.password: password of the MySQL password
    - mysql.host: your MySQL host
    - mysql.port: yout MySQL port
or
    - mysql.socket: your MySQL unix socket

  - For Redis

    - redis.cache_url: redis url 
    - redis.pool_size: connection pool size

## Setup database
- `rails db:setup`

## Start the application
```
bundle exec rails -s
```

## Testing

### Running all the tests
```
rspec
``` 

In order to run the feature specs, the suite relies on `geckodriver`. You can run the following command to install it for the project:

```
RAILS_ENV=test rails webdrivers:geckodriver:update
```

## Using Docker for Development

The `docker-compose.yml` contains the required configuration to launch both the Redis and MySQL instance.

Run: 
```
docker-compose -f ./docker/docker-compose.yml -p compliance up -d
```