# frozen_string_literal: true

module V1
  # Defines the Families controller
  class FamiliesController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total_record_count: MandateGroup.families.count
      }
    end
  end
end
