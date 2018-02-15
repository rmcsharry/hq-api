Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.dsn = Rails.application.secrets.sentry_dsn
end
