# frozen_string_literal: true

module V1
  # Defines the Mandate Groups controller
  class MandateGroupsController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      type_filter = params.dig(:filter, :group_type)
      total_record_count = if type_filter.present?
                             type_filter == 'family' ? MandateGroup.families.count : MandateGroup.organizations.count
                           else
                             MandateGroup.count
                           end
      {
        total_record_count: total_record_count
      }
    end
  end
end
