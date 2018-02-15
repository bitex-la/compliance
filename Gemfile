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
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'activeadmin'
gem 'devise'
gem 'cancancan'
gem 'draper'
gem "paperclip", "4.3.6"
gem 'country_select'
gem 'aasm'

gem 'fast_jsonapi'
gem 'active_model_serializers', '~> 0.10.0'
gem 'jsonapi_mapper', :git => 'https://github.com/bitex-la/jsonapi-mapper.git'

gem 'kaminari'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'capybara'
  gem 'geckodriver-helper'
  gem 'factory_bot_rails'
  gem 'dotenv-rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'foreman'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
