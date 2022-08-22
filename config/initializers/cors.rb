settings = Settings.cors
Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: settings.debug do
  allow do
    origins(settings.allowed_origins)
    resource '*', headers: :any, methods: :any
  end
end
