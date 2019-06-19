require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Compliance
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.eager_load_paths << "lib"
    config.autoload_paths << "lib"
    #config.paths.add "lib",             eager_load: true
    #config.paths.add "app/serializers", eager_load: true
    #config.paths.add "app/services",    eager_load: true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    require_relative "../app/models/settings"
    config.secret_key_base = Settings.secret_key_base

    #config.after_initialize do
    #  Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| require_dependency f}
    #end

    initializer 'serializers.install' do
      unless Rails.configuration.cache_classes
        ActiveSupport::Reloader.to_prepare do
          Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| load f}
        end
      end
    end
  end
end