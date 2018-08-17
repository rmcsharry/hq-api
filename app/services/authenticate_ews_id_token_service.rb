# frozen_string_literal: true

# Service for authenticating ews id tokens
class AuthenticateEWSIdTokenService < ApplicationService
  def self.call(id_token)
    decoded_token = DecodeEWSIdTokenService.call id_token
    appctx = JSON.parse(decoded_token['appctx'])
    User.find_by ews_user_id: appctx['msexchuid']
  end
end
