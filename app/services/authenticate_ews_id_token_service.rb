# frozen_string_literal: true

# Service for authenticating ews id tokens
class AuthenticateEWSIdTokenService < ApplicationService
  def self.call(id_token)
    decoded_token = decode_token id_token
    appctx = JSON.parse(decoded_token['appctx'])
    User.find_by ews_user_id: appctx['msexchuid']
  end

  class << self
    private

    # Token validation according to:
    # https://github.com/OfficeDev/outlook-dev-docs/blob/master/docs/add-ins/validate-an-identity-token.md
    def decode_token(id_token)
      JWT.decode(
        id_token,
        public_key,
        true,
        algorithm: 'RS256',
        typ: 'JWT'
      ).first
    end

    def public_key
      @public_key = OpenSSL::PKey::RSA.new ENV['EWS_AUTH_PUBLIC_KEY'].gsub('\\n', "\n")
    end
  end
end
