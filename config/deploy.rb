# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

unless ENV['compliance_host']
  puts "Invoke setting compliance_host environment var"
  exit
end

app_name = "compliance"
set :application, "compliance"
set :repo_url, "git@github.com:bitex-la/compliance.git"
set :user, "ubuntu"

set :deploy_to, "/home/ubuntu/apps/#{app_name}"

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma.error.log"
set :puma_error_log,  "#{shared_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

set :linked_files, %w{ config/settings.yml config/appsignal.yml }
set :linked_dirs, %w{log tmp/cache tmp/pids}

set(:ssh_options, fetch(:ssh_options, { }).merge!(
  forward_agent: true,
  user: fetch(:user),
  keepalive: true,
  keepalive_interval: 30
))

set :rbenv_type, :user
set :rbenv_custom_path, '/home/ubuntu/.rbenv'
set :rbenv_ruby, File.read(File.expand_path('../../.ruby-version', __FILE__)).strip

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      branch = if fetch(:stage) == :production
        set(:branch, 'master')
      else
        ask(:branch, `git branch`.match(/\* (\S+)\s/m)[1])
      end
      
      branch = fetch(:branch)
      unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
        puts "WARNING: local #{branch} is not the same as origin/#{branch}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
