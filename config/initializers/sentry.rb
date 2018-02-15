Raven.configure do |config|
  config.dsn = Rails.application.secrets.sentry_url
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
