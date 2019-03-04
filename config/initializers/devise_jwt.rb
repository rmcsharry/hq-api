# frozen_string_literal: true

# See https://github.com/waiting-for-dev/devise-jwt/issues/12 and https://github.com/plataformatec/devise/issues/4584
# Can hopefully be removed when upgrading to devise v5.0
module Devise
  module JWT
    # Adapt WardenStrategy to authenticate so that devise trackable is not updated on every endpoint call
    module WardenStrategy
      def authenticate!
        super
        env['devise.skip_trackable'] = true if valid?
      end
    end
  end
end

# We are overriding the `find_user` method of the JWT authorization here
# in order to remember manual scopes on consecutively issued JWT
# For the original file, see:
# https://github.com/waiting-for-dev/warden-jwt_auth/blob/master/lib/warden/jwt_auth/payload_user_helper.rb
module Warden
  module JWTAuth
    # Helper functions to deal with user info present in a decode payload
    module PayloadUserHelper
      # Returns user encoded in given payload
      #
      # @param payload [Hash] JWT payload
      # @return [Interfaces::User] an user, whatever it is
      def self.find_user(payload)
        config = JWTAuth.config
        scope = payload['scp'].to_sym
        user_repo = config.mappings[scope]
        user = user_repo.find_for_jwt_authentication(payload['sub'])
        user.authenticated_via_ews = payload['scope'] == 'ews'
        user
      end
    end
  end
end

Warden::JWTAuth::Strategy.prepend Devise::JWT::WardenStrategy
