if Rails.application.secrets.sentry_dsn
  Raven.configure do |config|
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    uri = URI.parse(Rails.application.secrets.sentry_dsn)
    p uri
    uri_path = uri.path.split('/')
    p uri_path
    config.dsn = Rails.application.secrets.sentry_dsn
  end
end
