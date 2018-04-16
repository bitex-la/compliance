set :stage, :demo
set :rails_env, 'demo'

fetch(:ssh_options, { }).store(:keys, %w{config/permission.pem})

server '23.21.231.213', roles: [:web, :app, :db], primary: true

set :pty,             true
set :use_sudo,        false
