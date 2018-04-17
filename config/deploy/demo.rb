set :stage, :demo
set :rails_env, 'demo'

server '23.21.231.213', roles: [:web, :app, :db], primary: true

set :pty,             true
set :use_sudo,        false
