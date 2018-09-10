require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Compliance
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.paths.add "lib",             eager_load: true
    config.paths.add "app/serializers", eager_load: true
    config.paths.add "app/services",    eager_load: true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # rack cache configuration
    config.action_dispatch.rack_cache = {
      verbose:     true,
      metastore:   ENV['RACK_CACHE_META_STORE'] || 'file:/tmp/cache/rack/meta',
      entitystore: ENV['RACK_CACHE_ENTITY_STORE'] || 'file:/tmp/cache/rack/meta'
    }
  end
end
