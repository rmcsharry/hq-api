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

Warden::JWTAuth::Strategy.prepend Devise::JWT::WardenStrategy
