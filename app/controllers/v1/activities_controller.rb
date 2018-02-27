module V1
  # Defines the Activities controller
  class ActivitiesController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total: Activity.count
      }
    end
  end
end
