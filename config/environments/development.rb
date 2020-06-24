Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, { url: Settings.redis.cache_url,
    namespace: Settings.redis.namespace,
    expires_in: 90.minutes,
    pool_size: Settings.redis.pool_size,

    error_handler: -> (method:, returning:, exception:) {
      ExceptionNotifier.notify_exception(exception)
    }
  }
    
    
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.after_initialize do
    #Bullet.enable = true
    #Bullet.bullet_logger = true
    #Bullet.console = true

    next if Rails.configuration.cache_classes
    ActiveSupport::Reloader.to_prepare do
      Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| load f}
    end
  end
end
