# frozen_string_literal: true

# Service for decoding ews id tokens
class DecodeEWSIdTokenService < ApplicationService
  def self.call(id_token)
    decode_token id_token
  end

  class << self
    private

    # Token validation according to:
    # https://github.com/OfficeDev/outlook-dev-docs/blob/master/docs/add-ins/validate-an-identity-token.md
    def decode_token(id_token)
      validate_payload(id_token)

      jwt_options = {
        algorithm: 'RS256',
        aud: valid_auds,
        nbf_leeway: 60,
        typ: 'JWT',
        verify_aud: true
      }

      JWT.decode(id_token, public_key, true, jwt_options).first
    end

    def decoded_parts(id_token)
      id_token.split('.')[0..1].map do |part|
        begin
          JSON.parse(Base64.decode64(part))
        rescue JSON::ParserError => _
          {}
        end
      end
    end

    def public_key
      @public_key = OpenSSL::PKey::RSA.new ENV['EWS_AUTH_PUBLIC_KEY'].gsub('\\n', "\n")
    end

    def validate_payload(id_token)
      header, payload = decoded_parts(id_token)
      raise JWT::VerificationError if header['x5t'].blank?

      validate_appctx payload['appctx']
    end

    def valid_auds
      ENV['OUTLOOK_ORIGINS'].split(',').map do |host|
        host_with_scheme = host.starts_with?('http') ? host : "https://#{host}"
        URI.join(host_with_scheme, 'index.html').to_s
      end
    end

    def validate_appctx(raw_appctx)
      appctx = JSON.parse(raw_appctx)
      raise JWT::InvalidPayload if appctx['version'] != 'ExIdTok.V1'
      raise JWT::InvalidPayload if appctx['amurl'] !~ URI::ABS_URI
    rescue JSON::ParserError, TypeError => _
      raise JWT::VerificationError
    end
  end
end
