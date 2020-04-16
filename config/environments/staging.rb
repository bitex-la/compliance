Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false

  # Attempt to read encrypted secrets from `config/secrets.yml.enc`.
  # Requires an encryption key in `ENV["RAILS_MASTER_KEY"]` or
  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  #config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  #config.public_file_server.enabled = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, { url: Settings.redis.cache_url,
    namespace: Settings.redis.namespace,
    connect_timeout: 30,  # Defaults to 20 seconds
    read_timeout:    0.2, # Defaults to 1 second
    write_timeout:   0.2, # Defaults to 1 second
    expires_in: 10.minutes,
    pool_size: Settings.redis.pool_size,

    error_handler: -> (method:, returning:, exception:) {
      ExceptionNotifier.notify_exception(exception)
    }
  }

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "compliance_#{Rails.env}"
  config.active_job.queue_adapter = :sidekiq
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # setup paperclip
  config.paperclip_defaults = {
    storage: :s3,
    preserve_files: true,
    s3_region: 'us-east-1',
    s3_credentials: {
      access_key_id: Settings.s3.aws_access_key_id,
      secret_access_key: Settings.s3.aws_secret_access_key
    },
    bucket: Settings.s3.attachments_bucket
  }

  config.action_mailer.smtp_settings = {
    address: "email-smtp.us-east-1.amazonaws.com",
    port: 587,
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: Settings.ses.access_key,
    password: Settings.ses.secret
  }

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  Rails.application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[compliance_bitex.la][staging]",
    :sender_address => %{"notifier" <hola@bitex.la>},
    :exception_recipients => Settings.exception_recipients.strip.split(',')
  }
end
