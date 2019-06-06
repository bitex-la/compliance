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
- [ ] Rename config/settings.example.yml file to config/settings.yml and set the following variables:
    - mysql.username: username of MySQL user
    - mysql.password: password of the MySQL password
    - mysql.host: your MySQL host
    - mysql.port: yout MySQL port
or
    - mysql.socket: your MySQL unix socket

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
