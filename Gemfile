source 'https://rubygems.org'

ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
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
gem 'activeadmin'
gem 'haml'
gem 'devise'
gem 'cancancan'
gem 'draper'
gem 'aws-sdk', '< 2.0'
gem "paperclip", "4.3.6"
gem 'country_select'
gem 'aasm'
gem 'zipline'

gem 'fast_jsonapi', github: 'netflix/fast_jsonapi'
gem 'active_model_serializers', '~> 0.10.0'
gem 'jsonapi_mapper', github: 'bitex-la/jsonapi-mapper'
gem 'static_models', github: 'dev-yohan/static_models', branch: 'rails-5-support'

gem 'kaminari'

gem 'timecop'

group :development, :test do
  gem 'dotenv-rails'
end

group :test do 
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'geckodriver-helper'
  gem 'factory_bot'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'geckodriver-helper'
  gem 'factory_bot'
  gem 'database_cleaner'
end

group :development do
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-bundler', '~> 1.1.2', require: false
  gem 'capistrano-rbenv', '~> 2.0.2', require: false
  gem 'capistrano-rbenv-install', require: false
  gem 'capistrano3-puma',   require: false
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'foreman'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'yajl-ruby', require: 'yajl'
