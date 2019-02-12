# frozen_string_literal: true

Mailjet.configure do |config|
  config.api_key = Rails.application.secrets.mailjet_api_key
  config.secret_key = Rails.application.secrets.mailjet_secret_key
end
