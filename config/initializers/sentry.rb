if Rails.application.secrets.sentry_dsn.present?
  Raven.configure do |config|
    p Rails.application.secrets.sentry_dsn
    p Rails.application.secrets.sentry_dsn.class
    uri = URI.parse(Rails.application.secrets.sentry_dsn)
    p uri
    config.dsn = Rails.application.secrets.sentry_dsn
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
