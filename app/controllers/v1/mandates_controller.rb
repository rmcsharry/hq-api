module V1
  # Defines the Mandates controller
  class MandatesController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total: Mandate.count
      }
    end
  end
end
