source 'https://rubygems.org'

ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.3'
gem 'puma', '~> 3.7'
gem 'mysql2'

gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass'
gem 'compass-rails'
gem 'font-awesome-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'settingslogic'
gem 'activeadmin', '>= 1.4.3'
gem 'activeadmin_addons'
gem 'active_model_otp', github: 'heapsource/active_model_otp', branch: 'master'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'countries'
gem 'haml'
gem 'devise'
gem 'cancancan'
gem 'draper'
gem 'aws-sdk-s3', '~> 1.30.0'
gem "paperclip", "~>6.1.0"
gem 'aasm'
gem 'rubyzip'

gem 'fast_jsonapi', github: 'netflix/fast_jsonapi'
gem 'active_model_serializers', '~> 0.10.0'
gem 'jsonapi_mapper', github: 'bitex-la/jsonapi-mapper'
gem 'static_models', github: 'bitex-la/static_models'

gem 'kaminari'
gem 'timecop'

# field sanitization
gem 'strip_attributes'

# cache
gem 'actionpack-action_caching'

# exception notifier
gem 'exception_notification'

# monitoring
gem 'appsignal'

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'yajl-ruby', require: 'yajl'

gem 'hashie'

gem 'prawn'
gem 'prawn-table'

gem 'connection_pool'
gem 'redis-objects'
gem 'redis-store'

group :development, :test do 
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do 
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'geckodriver-helper'
  gem 'factory_bot'
  gem 'faker'
  gem 'database_cleaner'
  gem 'rspec_junit_formatter', '0.2.2'
end

group :development do
  gem 'bullet'
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-bundler', '~> 1.1.2', require: false
  gem 'capistrano-rbenv', '~> 2.0.2', require: false
  gem 'capistrano-rbenv-install', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rails-db', require: false
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end
