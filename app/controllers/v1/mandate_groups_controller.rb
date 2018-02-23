module V1
  # Defines the Mandate Groups controller
  class MandateGroupsController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total: MandateGroup.count
      }
    end
  end
end
