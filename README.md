# README

## Install pre-requisites
- [ ] Install [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
- [ ] Setup a local mySQL server
- [ ] Install dependencies and setup development tools
  ```
    bundle install
    bundle binstubs bundler --force
    bundle binstubs foreman
  ```

## Environment variables
- [ ] Rename .env.example file to .env or set the following environment variables:
    - MYSQL_USERNAME: username of MySQL user
    - MYSQL_PASSWORD: password of the MySQL password
    - MYSQL_HOST: your MySQL host
    - MYSQL_PORT: yout MySQL port
    - MYSQL_SOCKET: your MySQL unix socket

## Create database 
- [ ] `rails db:create`
- [ ] `rails db:schema:load`

## Start the application
```
bin/foreman start
```

## Testing

### Running all the tests
```
rspec
``` 
