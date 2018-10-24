# frozen_string_literal: true

require Rails.root.join('config', 'environments', 'development')

Rails.application.configure do
  # Settings specified here are inherited from development.rb and will
  # take precedence over those in config/application.rb.

  # Silence most logs for integration testing
  config.log_level = :fatal
end
